package metrics

import (
	"math"
	"net/http"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"time"
)

const MetricsPath = "/metrics"

// durationBuckets are the upper bounds, in seconds, of the request duration
// histogram. The service answers in well under a millisecond, so the lower
// bounds are tight; the upper ones exist to keep timeouts and stalls visible.
var durationBuckets = []float64{
	0.001, 0.0025, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10,
}

type Collector struct {
	up        atomic.Int64
	mu        sync.RWMutex
	requests  map[requestKey]*atomic.Uint64
	durations map[durationKey]*histogram
}

type requestKey struct {
	route  string
	method string
	status int
}

// durationKey deliberately omits status: route and method are enough to read
// latency, and leaving status out keeps the bucket series count bounded.
type durationKey struct {
	route  string
	method string
}

func NewCollector() *Collector {
	collector := &Collector{
		requests:  make(map[requestKey]*atomic.Uint64),
		durations: make(map[durationKey]*histogram),
	}
	collector.up.Store(1)
	return collector
}

func (c *Collector) Handler() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			w.Header().Set("Allow", http.MethodGet)
			http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
			return
		}

		w.Header().Set("Content-Type", "text/plain; version=0.0.4; charset=utf-8")
		_, _ = w.Write([]byte(c.Render()))
	})
}

func (c *Collector) Middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		recorder := &statusRecorder{ResponseWriter: w, status: http.StatusOK}
		start := time.Now()
		next.ServeHTTP(recorder, r)
		c.Record(routeLabel(r.URL.Path), r.Method, recorder.status, time.Since(start))
	})
}

func (c *Collector) Record(route string, method string, status int, duration time.Duration) {
	route = routeLabel(route)
	c.countRequest(requestKey{route: route, method: method, status: status})
	c.observeDuration(durationKey{route: route, method: method}, duration.Seconds())
}

func (c *Collector) countRequest(key requestKey) {
	c.mu.RLock()
	counter := c.requests[key]
	c.mu.RUnlock()
	if counter != nil {
		counter.Add(1)
		return
	}

	c.mu.Lock()
	counter = c.requests[key]
	if counter == nil {
		counter = &atomic.Uint64{}
		c.requests[key] = counter
	}
	c.mu.Unlock()
	counter.Add(1)
}

func (c *Collector) observeDuration(key durationKey, seconds float64) {
	c.mu.RLock()
	observed := c.durations[key]
	c.mu.RUnlock()
	if observed != nil {
		observed.observe(seconds)
		return
	}

	c.mu.Lock()
	observed = c.durations[key]
	if observed == nil {
		observed = newHistogram()
		c.durations[key] = observed
	}
	c.mu.Unlock()
	observed.observe(seconds)
}

func (c *Collector) Render() string {
	var builder strings.Builder
	builder.WriteString("# HELP projeto_korp_up Application availability indicator.\n")
	builder.WriteString("# TYPE projeto_korp_up gauge\n")
	builder.WriteString("projeto_korp_up ")
	builder.WriteString(strconv.FormatInt(c.up.Load(), 10))
	builder.WriteByte('\n')

	c.mu.RLock()
	defer c.mu.RUnlock()

	builder.WriteString("# HELP projeto_korp_http_requests_total HTTP requests handled by route, method and status.\n")
	builder.WriteString("# TYPE projeto_korp_http_requests_total counter\n")
	for key, counter := range c.requests {
		builder.WriteString("projeto_korp_http_requests_total{route=")
		builder.WriteString(strconv.Quote(key.route))
		builder.WriteString(",method=")
		builder.WriteString(strconv.Quote(key.method))
		builder.WriteString(",status=")
		builder.WriteString(strconv.Quote(strconv.Itoa(key.status)))
		builder.WriteString("} ")
		builder.WriteString(strconv.FormatUint(counter.Load(), 10))
		builder.WriteByte('\n')
	}

	builder.WriteString("# HELP projeto_korp_http_request_duration_seconds HTTP request duration in seconds by route and method.\n")
	builder.WriteString("# TYPE projeto_korp_http_request_duration_seconds histogram\n")
	for key, observed := range c.durations {
		labels := "route=" + strconv.Quote(key.route) + ",method=" + strconv.Quote(key.method)
		cumulative := uint64(0)
		for i, upper := range durationBuckets {
			cumulative += observed.counts[i].Load()
			builder.WriteString("projeto_korp_http_request_duration_seconds_bucket{")
			builder.WriteString(labels)
			builder.WriteString(",le=")
			builder.WriteString(strconv.Quote(strconv.FormatFloat(upper, 'g', -1, 64)))
			builder.WriteString("} ")
			builder.WriteString(strconv.FormatUint(cumulative, 10))
			builder.WriteByte('\n')
		}

		total := observed.count.Load()
		builder.WriteString("projeto_korp_http_request_duration_seconds_bucket{")
		builder.WriteString(labels)
		builder.WriteString(`,le="+Inf"} `)
		builder.WriteString(strconv.FormatUint(total, 10))
		builder.WriteByte('\n')

		builder.WriteString("projeto_korp_http_request_duration_seconds_sum{")
		builder.WriteString(labels)
		builder.WriteString("} ")
		builder.WriteString(strconv.FormatFloat(observed.sum(), 'g', -1, 64))
		builder.WriteByte('\n')

		builder.WriteString("projeto_korp_http_request_duration_seconds_count{")
		builder.WriteString(labels)
		builder.WriteString("} ")
		builder.WriteString(strconv.FormatUint(total, 10))
		builder.WriteByte('\n')
	}

	return builder.String()
}

// histogram keeps per-bucket counts, not cumulative ones; Render accumulates
// them. Observations above the last bucket are counted only in count, which is
// what the +Inf bucket reports.
type histogram struct {
	counts  []atomic.Uint64
	sumBits atomic.Uint64
	count   atomic.Uint64
}

func newHistogram() *histogram {
	return &histogram{counts: make([]atomic.Uint64, len(durationBuckets))}
}

func (h *histogram) observe(seconds float64) {
	for i, upper := range durationBuckets {
		if seconds <= upper {
			h.counts[i].Add(1)
			break
		}
	}

	h.count.Add(1)
	for {
		current := h.sumBits.Load()
		next := math.Float64bits(math.Float64frombits(current) + seconds)
		if h.sumBits.CompareAndSwap(current, next) {
			return
		}
	}
}

func (h *histogram) sum() float64 {
	return math.Float64frombits(h.sumBits.Load())
}

func routeLabel(path string) string {
	switch path {
	case "/projeto-korp", "/health", MetricsPath:
		return path
	default:
		return "unknown"
	}
}

type statusRecorder struct {
	http.ResponseWriter
	status int
}

func (r *statusRecorder) WriteHeader(status int) {
	r.status = status
	r.ResponseWriter.WriteHeader(status)
}

func (r *statusRecorder) Write(body []byte) (int, error) {
	if r.status == 0 {
		r.status = http.StatusOK
	}
	return r.ResponseWriter.Write(body)
}
