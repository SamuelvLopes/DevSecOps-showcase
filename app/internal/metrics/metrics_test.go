package metrics

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"
	"time"
)

func TestCollectorRendersAvailabilityAndRequestVolume(t *testing.T) {
	collector := NewCollector()
	collector.Record("/projeto-korp", http.MethodGet, http.StatusOK, time.Millisecond)
	collector.Record("/projeto-korp", http.MethodGet, http.StatusOK, time.Millisecond)
	collector.Record("/missing", http.MethodGet, http.StatusNotFound, time.Millisecond)

	body := collector.Render()

	for _, want := range []string{
		"projeto_korp_up 1\n",
		`projeto_korp_http_requests_total{route="/projeto-korp",method="GET",status="200"} 2`,
		`projeto_korp_http_requests_total{route="unknown",method="GET",status="404"} 1`,
	} {
		if !strings.Contains(body, want) {
			t.Fatalf("metrics body does not contain %q:\n%s", want, body)
		}
	}
}

func TestCollectorRendersDurationHistogram(t *testing.T) {
	collector := NewCollector()
	// 2 ms falls in the 0.0025 bucket, 40 ms in the 0.05 bucket.
	collector.Record("/projeto-korp", http.MethodGet, http.StatusOK, 2*time.Millisecond)
	collector.Record("/projeto-korp", http.MethodGet, http.StatusOK, 40*time.Millisecond)

	body := collector.Render()

	for _, want := range []string{
		"# TYPE projeto_korp_http_request_duration_seconds histogram\n",
		// Below the first observation nothing is counted, and buckets are cumulative.
		`projeto_korp_http_request_duration_seconds_bucket{route="/projeto-korp",method="GET",le="0.001"} 0`,
		`projeto_korp_http_request_duration_seconds_bucket{route="/projeto-korp",method="GET",le="0.0025"} 1`,
		`projeto_korp_http_request_duration_seconds_bucket{route="/projeto-korp",method="GET",le="0.025"} 1`,
		`projeto_korp_http_request_duration_seconds_bucket{route="/projeto-korp",method="GET",le="0.05"} 2`,
		`projeto_korp_http_request_duration_seconds_bucket{route="/projeto-korp",method="GET",le="+Inf"} 2`,
		`projeto_korp_http_request_duration_seconds_sum{route="/projeto-korp",method="GET"} 0.042`,
		`projeto_korp_http_request_duration_seconds_count{route="/projeto-korp",method="GET"} 2`,
	} {
		if !strings.Contains(body, want) {
			t.Fatalf("metrics body does not contain %q:\n%s", want, body)
		}
	}
}

// An observation above the last bucket must still reach +Inf and count.
func TestCollectorRendersObservationAboveLastBucket(t *testing.T) {
	collector := NewCollector()
	collector.Record("/health", http.MethodGet, http.StatusNoContent, 30*time.Second)

	body := collector.Render()

	for _, want := range []string{
		`projeto_korp_http_request_duration_seconds_bucket{route="/health",method="GET",le="10"} 0`,
		`projeto_korp_http_request_duration_seconds_bucket{route="/health",method="GET",le="+Inf"} 1`,
		`projeto_korp_http_request_duration_seconds_count{route="/health",method="GET"} 1`,
	} {
		if !strings.Contains(body, want) {
			t.Fatalf("metrics body does not contain %q:\n%s", want, body)
		}
	}
}

// The histogram omits status on purpose, so requests differing only by status
// share a single series.
func TestDurationHistogramGroupsStatusTogether(t *testing.T) {
	collector := NewCollector()
	collector.Record("/projeto-korp", http.MethodGet, http.StatusOK, time.Millisecond)
	collector.Record("/projeto-korp", http.MethodGet, http.StatusInternalServerError, time.Millisecond)

	body := collector.Render()

	want := `projeto_korp_http_request_duration_seconds_count{route="/projeto-korp",method="GET"} 2`
	if !strings.Contains(body, want) {
		t.Fatalf("metrics body does not contain %q:\n%s", want, body)
	}
	if strings.Contains(body, `projeto_korp_http_request_duration_seconds_count{route="/projeto-korp",method="GET",status=`) {
		t.Fatalf("duration histogram must not carry a status label:\n%s", body)
	}
}

func TestConcurrentRecordKeepsCountsConsistent(t *testing.T) {
	collector := NewCollector()
	const workers, perWorker = 8, 100

	var group sync.WaitGroup
	group.Add(workers)
	for range workers {
		go func() {
			defer group.Done()
			for range perWorker {
				collector.Record("/projeto-korp", http.MethodGet, http.StatusOK, time.Millisecond)
			}
		}()
	}
	group.Wait()

	body := collector.Render()
	for _, want := range []string{
		`projeto_korp_http_requests_total{route="/projeto-korp",method="GET",status="200"} 800`,
		`projeto_korp_http_request_duration_seconds_count{route="/projeto-korp",method="GET"} 800`,
		`projeto_korp_http_request_duration_seconds_bucket{route="/projeto-korp",method="GET",le="+Inf"} 800`,
	} {
		if !strings.Contains(body, want) {
			t.Fatalf("metrics body does not contain %q:\n%s", want, body)
		}
	}
}

func TestMetricsHandler(t *testing.T) {
	collector := NewCollector()
	recorder := httptest.NewRecorder()

	collector.Handler().ServeHTTP(recorder, httptest.NewRequest(http.MethodGet, MetricsPath, nil))

	if recorder.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", recorder.Code, http.StatusOK)
	}
	if got := recorder.Header().Get("Content-Type"); got != "text/plain; version=0.0.4; charset=utf-8" {
		t.Fatalf("Content-Type = %q, want Prometheus text format", got)
	}
	if !strings.Contains(recorder.Body.String(), "projeto_korp_up 1\n") {
		t.Fatalf("metrics body = %q, want up gauge", recorder.Body.String())
	}
}

func TestMetricsHandlerRejectsOtherMethods(t *testing.T) {
	recorder := httptest.NewRecorder()

	NewCollector().Handler().ServeHTTP(recorder, httptest.NewRequest(http.MethodPost, MetricsPath, nil))

	if recorder.Code != http.StatusMethodNotAllowed {
		t.Fatalf("status = %d, want %d", recorder.Code, http.StatusMethodNotAllowed)
	}
	if got := recorder.Header().Get("Allow"); got != http.MethodGet {
		t.Fatalf("Allow = %q, want GET", got)
	}
}

func TestMiddlewareRecordsRouteMethodAndStatus(t *testing.T) {
	collector := NewCollector()
	handler := collector.Middleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusAccepted)
	}))

	handler.ServeHTTP(httptest.NewRecorder(), httptest.NewRequest(http.MethodGet, "/health", nil))

	body := collector.Render()
	want := `projeto_korp_http_requests_total{route="/health",method="GET",status="202"} 1`
	if !strings.Contains(body, want) {
		t.Fatalf("metrics body does not contain %q:\n%s", want, body)
	}
}

func TestMiddlewareRecordsDuration(t *testing.T) {
	collector := NewCollector()
	handler := collector.Middleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	handler.ServeHTTP(httptest.NewRecorder(), httptest.NewRequest(http.MethodGet, "/projeto-korp", nil))

	body := collector.Render()
	want := `projeto_korp_http_request_duration_seconds_count{route="/projeto-korp",method="GET"} 1`
	if !strings.Contains(body, want) {
		t.Fatalf("metrics body does not contain %q:\n%s", want, body)
	}
}
