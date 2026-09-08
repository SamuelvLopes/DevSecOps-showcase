package metrics

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestCollectorRendersAvailabilityAndRequestVolume(t *testing.T) {
	collector := NewCollector()
	collector.Record("/projeto-korp", http.MethodGet, http.StatusOK)
	collector.Record("/projeto-korp", http.MethodGet, http.StatusOK)
	collector.Record("/missing", http.MethodGet, http.StatusNotFound)

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
