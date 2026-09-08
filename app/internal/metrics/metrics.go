package metrics

import (
	"net/http"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
)

const MetricsPath = "/metrics"

type Collector struct {
	up       atomic.Int64
	mu       sync.RWMutex
	requests map[requestKey]*atomic.Uint64
}

type requestKey struct {
	route  string
	method string
	status int
}

func NewCollector() *Collector {
	collector := &Collector{
		requests: make(map[requestKey]*atomic.Uint64),
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
		next.ServeHTTP(recorder, r)
		c.Record(routeLabel(r.URL.Path), r.Method, recorder.status)
	})
}

func (c *Collector) Record(route string, method string, status int) {
	key := requestKey{route: routeLabel(route), method: method, status: status}

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

func (c *Collector) Render() string {
	var builder strings.Builder
	builder.WriteString("# HELP projeto_korp_up Application availability indicator.\n")
	builder.WriteString("# TYPE projeto_korp_up gauge\n")
	builder.WriteString("projeto_korp_up ")
	builder.WriteString(strconv.FormatInt(c.up.Load(), 10))
	builder.WriteByte('\n')
	builder.WriteString("# HELP projeto_korp_http_requests_total HTTP requests handled by route, method and status.\n")
	builder.WriteString("# TYPE projeto_korp_http_requests_total counter\n")

	c.mu.RLock()
	defer c.mu.RUnlock()
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

	return builder.String()
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
