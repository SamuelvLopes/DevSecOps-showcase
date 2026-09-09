# KORP-046 — Tempo e OpenTelemetry na aplicação Go

Status: done. Risco: médio. Depende de KORP-042.

## Objetivo

Adicionar tracing básico com OpenTelemetry na aplicação Go e envio para Tempo no
ambiente Kubernetes opcional.

## Implementação e limites

A instrumentação deve ser mínima: tracer provider, exporter OTLP configurável por
variáveis de ambiente e spans do fluxo HTTP. O app deve continuar funcionando sem
backend de tracing.

## Aceite e verificação

- [x] Bootstrap OpenTelemetry na aplicação.
- [x] Variáveis de ambiente para habilitar OTLP.
- [x] Valores Helm para Tempo.
- [x] Documentação de consulta/uso de trace no Grafana.
- [x] Testes Go continuam verdes.

## Segurança, observabilidade e recuperação

Traces não devem incluir payload, query string, IP, user-agent ou headers
sensíveis. Falha de exportação de trace não pode derrubar o endpoint.

## Evidências

- `app/internal/telemetry` adiciona bootstrap opt-in de OpenTelemetry.
- `charts/observability/tempo-values.yaml` versionado.
- Chart injeta `OTEL_TRACES_ENABLED`, `OTEL_EXPORTER_OTLP_ENDPOINT` e `OTEL_SERVICE_NAME` quando habilitado.
