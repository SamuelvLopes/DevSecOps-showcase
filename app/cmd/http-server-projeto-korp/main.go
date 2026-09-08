package main

import (
	"log"
	"net/http"
	"os"

	"github.com/SamuelvLopes/DevSecOps-showcase/app/internal/server"
)

func main() {
	address := os.Getenv("HTTP_ADDRESS")
	if address == "" {
		address = ":8080"
	}
	log.Printf("http-server-projeto-korp listening on %s", address)
	if err := http.ListenAndServe(address, server.NewHandler()); err != nil {
		log.Fatal(err)
	}
}
