package app

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/SamuelvLopes/DevSecOps-showcase/app/internal/server"
	"github.com/SamuelvLopes/DevSecOps-showcase/app/internal/telemetry"
)

const (
	defaultAddress         = ":8080"
	defaultReadTimeout     = 5 * time.Second
	defaultWriteTimeout    = 10 * time.Second
	defaultIdleTimeout     = 60 * time.Second
	defaultShutdownTimeout = 10 * time.Second
)

// NewHTTPServer applies conservative defaults for a small public HTTP service.
func NewHTTPServer(address string, handler http.Handler) *http.Server {
	if address == "" {
		address = defaultAddress
	}

	return &http.Server{
		Addr:              address,
		Handler:           handler,
		ReadHeaderTimeout: defaultReadTimeout,
		ReadTimeout:       defaultReadTimeout,
		WriteTimeout:      defaultWriteTimeout,
		IdleTimeout:       defaultIdleTimeout,
	}
}

func Run(ctx context.Context, logger *slog.Logger, address string) error {
	if logger == nil {
		logger = slog.New(slog.NewJSONHandler(os.Stdout, nil))
	}

	telemetryShutdown, err := telemetry.Start(ctx, logger)
	if err != nil {
		return err
	}
	defer func() {
		shutdownCtx, cancel := context.WithTimeout(context.Background(), defaultShutdownTimeout)
		defer cancel()
		if err := telemetry.Shutdown(shutdownCtx, telemetryShutdown); err != nil {
			logger.Warn("opentelemetry shutdown failed", "error", err)
		}
	}()

	httpServer := NewHTTPServer(address, telemetry.WrapHandler(server.NewHandler()))
	errCh := make(chan error, 1)

	go func() {
		logger.Info("http server started", "address", httpServer.Addr)
		errCh <- httpServer.ListenAndServe()
	}()

	select {
	case err := <-errCh:
		if errors.Is(err, http.ErrServerClosed) {
			return nil
		}
		return err
	case <-ctx.Done():
		shutdownCtx, cancel := context.WithTimeout(context.Background(), defaultShutdownTimeout)
		defer cancel()

		logger.Info("http server shutting down", "address", httpServer.Addr)
		if err := httpServer.Shutdown(shutdownCtx); err != nil {
			return err
		}
		return nil
	}
}

func ContextWithSignals(parent context.Context) (context.Context, context.CancelFunc) {
	return signal.NotifyContext(parent, os.Interrupt, syscall.SIGTERM)
}
