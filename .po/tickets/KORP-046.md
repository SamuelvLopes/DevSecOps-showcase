# KORP-046 — Tempo e OpenTelemetry na aplicação Go

Status: planned. Risco: médio. Depende de KORP-042.

## Objetivo

Adicionar tracing básico com OpenTelemetry na aplicação Go e envio para Tempo no
ambiente Kubernetes opcional.

## Implementação e limites

A instrumentação deve ser mínima: tracer provider, exporter OTLP configurável por
variáveis de ambiente e spans do fluxo HTTP. O app deve continuar funcionando sem
backend de tracing.

## Aceite e verificação

- [ ] Bootstrap OpenTelemetry na aplicação.
- [ ] Variáveis de ambiente para habilitar OTLP.
- [ ] Valores Helm para Tempo.
- [ ] Documentação de consulta de trace no Grafana.
- [ ] Testes Go continuam verdes.

## Segurança, observabilidade e recuperação

Traces não devem incluir payload, query string, IP, user-agent ou headers
sensíveis. Falha de exportação de trace não pode derrubar o endpoint.

## Evidências

Pendentes para a implementação do ticket.
