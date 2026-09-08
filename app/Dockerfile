# syntax=docker/dockerfile:1

FROM golang:1.27-alpine AS build

WORKDIR /src
COPY go.mod ./
COPY cmd ./cmd
COPY internal ./internal

RUN CGO_ENABLED=0 GOOS=linux go build \
    -trimpath \
    -ldflags="-s -w" \
    -o /out/http-server-projeto-korp \
    ./cmd/http-server-projeto-korp

FROM scratch

USER 65532:65532
EXPOSE 8080
COPY --from=build /out/http-server-projeto-korp /http-server-projeto-korp

ENTRYPOINT ["/http-server-projeto-korp"]
