# KORP-045 — Loki e Alloy para logs Kubernetes

Status: done. Risco: médio. Depende de KORP-044.

## Objetivo

Adicionar coleta de logs Kubernetes com Loki e Grafana Alloy, integrando consulta
de logs no Grafana.

## Implementação e limites

Alloy deve ser o coletor principal. Promtail não será usado por padrão; pode ser
citado apenas como alternativa legada se necessário. Logs devem evitar payloads
sensíveis e aproveitar os logs JSON da aplicação.

## Aceite e verificação

- [x] Valores Helm para Loki.
- [x] Configuração Alloy para coletar logs de pods.
- [x] Consulta LogQL documentada para a aplicação.
- [x] CI valida templates da aplicação.

## Segurança, observabilidade e recuperação

Coleta deve preservar o padrão atual de não registrar corpo de requisição, query
string, IP, user-agent ou headers sensíveis.

## Evidências

- `charts/observability/loki-values.yaml` e `alloy-values.yaml` versionados.
- `docs/kubernetes-observability.md` documenta Loki, Alloy e LogQL.
