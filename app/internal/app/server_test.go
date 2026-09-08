package app

import (
	"net/http"
	"testing"
)

func TestNewHTTPServerUsesDefaultAddress(t *testing.T) {
	server := NewHTTPServer("", http.NewServeMux())

	if server.Addr != defaultAddress {
		t.Fatalf("Addr = %q, want %q", server.Addr, defaultAddress)
	}
}

func TestNewHTTPServerSetsOperationalTimeouts(t *testing.T) {
	server := NewHTTPServer(":18080", http.NewServeMux())

	if server.Addr != ":18080" {
		t.Fatalf("Addr = %q, want :18080", server.Addr)
	}
	if server.ReadHeaderTimeout != defaultReadTimeout {
		t.Fatalf("ReadHeaderTimeout = %s, want %s", server.ReadHeaderTimeout, defaultReadTimeout)
	}
	if server.ReadTimeout != defaultReadTimeout {
		t.Fatalf("ReadTimeout = %s, want %s", server.ReadTimeout, defaultReadTimeout)
	}
	if server.WriteTimeout != defaultWriteTimeout {
		t.Fatalf("WriteTimeout = %s, want %s", server.WriteTimeout, defaultWriteTimeout)
	}
	if server.IdleTimeout != defaultIdleTimeout {
		t.Fatalf("IdleTimeout = %s, want %s", server.IdleTimeout, defaultIdleTimeout)
	}
}
