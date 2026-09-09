package server

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"reflect"
	"testing"
	"time"
)

func TestProjectEndpoint(t *testing.T) {
	requestTime := time.Date(2026, time.September, 8, 17, 15, 30, 0, time.FixedZone("BRT", -3*60*60))
	handler := newHandler(func() time.Time { return requestTime })
	recorder := httptest.NewRecorder()

	handler.ServeHTTP(recorder, httptest.NewRequest(http.MethodGet, projectPath, nil))

	if recorder.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", recorder.Code, http.StatusOK)
	}
	if got := recorder.Header().Get("Content-Type"); got != "application/json" {
		t.Fatalf("Content-Type = %q, want application/json", got)
	}

	var response map[string]string
	if err := json.NewDecoder(recorder.Body).Decode(&response); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	want := map[string]string{
		"nome":    "Projeto Korp",
		"horario": "2026-09-08T20:15:30Z",
	}
	if !reflect.DeepEqual(response, want) {
		t.Fatalf("response = %#v, want %#v", response, want)
	}
}

func TestProjectEndpointReadsClockOnEachRequest(t *testing.T) {
	times := []time.Time{
		time.Date(2026, time.September, 8, 20, 15, 30, 0, time.UTC),
		time.Date(2026, time.September, 8, 20, 16, 30, 0, time.UTC),
	}
	calls := 0
	handler := newHandler(func() time.Time {
		value := times[calls]
		calls++
		return value
	})

	for _, want := range []string{"2026-09-08T20:15:30Z", "2026-09-08T20:16:30Z"} {
		recorder := httptest.NewRecorder()
		handler.ServeHTTP(recorder, httptest.NewRequest(http.MethodGet, projectPath, nil))

		var response projectResponse
		if err := json.NewDecoder(recorder.Body).Decode(&response); err != nil {
			t.Fatalf("decode response: %v", err)
		}
		if response.Horario != want {
			t.Fatalf("horario = %q, want %q", response.Horario, want)
		}
	}

	if calls != 2 {
		t.Fatalf("clock calls = %d, want 2", calls)
	}
}

func TestProjectEndpointRejectsOtherMethods(t *testing.T) {
	handler := newHandler(time.Now)
	recorder := httptest.NewRecorder()

	handler.ServeHTTP(recorder, httptest.NewRequest(http.MethodPost, projectPath, nil))

	if recorder.Code != http.StatusMethodNotAllowed {
		t.Fatalf("status = %d, want %d", recorder.Code, http.StatusMethodNotAllowed)
	}
	if got := recorder.Header().Get("Allow"); got != http.MethodGet {
		t.Fatalf("Allow = %q, want GET", got)
	}
}

func TestHealthEndpoint(t *testing.T) {
	handler := newHandler(time.Now)
	recorder := httptest.NewRecorder()

	handler.ServeHTTP(recorder, httptest.NewRequest(http.MethodGet, healthPath, nil))

	if recorder.Code != http.StatusNoContent {
		t.Fatalf("status = %d, want %d", recorder.Code, http.StatusNoContent)
	}
	if recorder.Body.Len() != 0 {
		t.Fatalf("body = %q, want empty", recorder.Body.String())
	}
}

func TestHealthEndpointRejectsOtherMethods(t *testing.T) {
	handler := newHandler(time.Now)
	recorder := httptest.NewRecorder()

	handler.ServeHTTP(recorder, httptest.NewRequest(http.MethodPost, healthPath, nil))

	if recorder.Code != http.StatusMethodNotAllowed {
		t.Fatalf("status = %d, want %d", recorder.Code, http.StatusMethodNotAllowed)
	}
	if got := recorder.Header().Get("Allow"); got != http.MethodGet {
		t.Fatalf("Allow = %q, want GET", got)
	}
}

func TestUnknownRouteReturnsNotFound(t *testing.T) {
	recorder := httptest.NewRecorder()
	newHandler(time.Now).ServeHTTP(recorder, httptest.NewRequest(http.MethodGet, "/unknown", nil))

	if recorder.Code != http.StatusNotFound {
		t.Fatalf("status = %d, want %d", recorder.Code, http.StatusNotFound)
	}
}
