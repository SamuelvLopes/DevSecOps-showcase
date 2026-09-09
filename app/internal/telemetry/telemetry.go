package telemetry

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"time"

	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.26.0"
)

const (
	enabledEnv     = "OTEL_TRACES_ENABLED"
	serviceNameEnv = "OTEL_SERVICE_NAME"
	defaultService = "http-server-projeto-korp"
)

func Enabled() bool {
	return os.Getenv(enabledEnv) == "true"
}

func WrapHandler(handler http.Handler) http.Handler {
	if !Enabled() {
		return handler
	}
	return otelhttp.NewHandler(handler, defaultService)
}

func Start(ctx context.Context, logger *slog.Logger) (func(context.Context) error, error) {
	if !Enabled() {
		return func(context.Context) error { return nil }, nil
	}

	serviceName := os.Getenv(serviceNameEnv)
	if serviceName == "" {
		serviceName = defaultService
	}

	exporter, err := otlptracehttp.New(ctx)
	if err != nil {
		return nil, err
	}

	res, err := resource.Merge(
		resource.Default(),
		resource.NewWithAttributes(
			semconv.SchemaURL,
			semconv.ServiceName(serviceName),
		),
	)
	if err != nil {
		return nil, err
	}

	provider := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exporter, sdktrace.WithBatchTimeout(time.Second)),
		sdktrace.WithResource(res),
	)
	otel.SetTracerProvider(provider)
	otel.SetTextMapPropagator(propagation.TraceContext{})

	if logger != nil {
		logger.Info("opentelemetry traces enabled", "service", serviceName)
	}

	return provider.Shutdown, nil
}

func Shutdown(ctx context.Context, shutdown func(context.Context) error) error {
	if shutdown == nil {
		return nil
	}
	if err := shutdown(ctx); err != nil && !errors.Is(err, context.Canceled) {
		return err
	}
	return nil
}
