package main

import (
	"context"
	"log/slog"
	"os"

	"github.com/SamuelvLopes/DevSecOps-showcase/app/internal/app"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	address := os.Getenv("HTTP_ADDRESS")

	ctx, stop := app.ContextWithSignals(context.Background())
	defer stop()

	if err := app.Run(ctx, logger, address); err != nil {
		logger.Error("http server stopped", "error", err)
		os.Exit(1)
	}
}
