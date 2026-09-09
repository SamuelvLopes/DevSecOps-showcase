package telemetry

import (
	"net/http"
	"testing"
)

func TestWrapHandlerDisabledReturnsOriginalHandler(t *testing.T) {
	t.Setenv(enabledEnv, "")

	handler := http.NewServeMux()
	wrapped := WrapHandler(handler)

	if wrapped != handler {
		t.Fatal("expected disabled telemetry to return original handler")
	}
}

func TestEnabled(t *testing.T) {
	t.Setenv(enabledEnv, "true")
	if !Enabled() {
		t.Fatal("expected telemetry to be enabled")
	}

	t.Setenv(enabledEnv, "false")
	if Enabled() {
		t.Fatal("expected telemetry to be disabled")
	}
}
