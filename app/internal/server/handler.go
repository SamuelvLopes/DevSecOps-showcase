package server

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/SamuelvLopes/DevSecOps-showcase/app/internal/metrics"
)

const (
	healthPath  = "/health"
	projectPath = "/projeto-korp"
)

type clock func() time.Time

type projectResponse struct {
	Nome    string `json:"nome"`
	Horario string `json:"horario"`
}

// NewHandler returns the HTTP handler for the project service.
func NewHandler() http.Handler {
	return newHandler(time.Now)
}

func newHandler(now clock) http.Handler {
	collector := metrics.NewCollector()
	mux := http.NewServeMux()
	mux.Handle(metrics.MetricsPath, collector.Handler())
	mux.HandleFunc(healthPath, func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			w.Header().Set("Allow", http.MethodGet)
			http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
			return
		}

		w.WriteHeader(http.StatusNoContent)
	})

	mux.HandleFunc(projectPath, func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			w.Header().Set("Allow", http.MethodGet)
			http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		response := projectResponse{
			Nome:    "Projeto Korp",
			Horario: now().UTC().Format(time.RFC3339),
		}

		if err := json.NewEncoder(w).Encode(response); err != nil {
			http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		}
	})

	return collector.Middleware(mux)
}
