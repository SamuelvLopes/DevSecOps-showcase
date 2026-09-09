# KORP-048 — Release v1.1.0 Kubernetes observability

Status: in_review. Risco: médio. Depende de KORP-042, KORP-044, KORP-045, KORP-046 e KORP-047.

## Objetivo

Promover para `main` a trilha Kubernetes e observabilidade LGTM adicionada em
`develop`.

## Implementação e limites

A release v1.1.0 adiciona Helm, ServiceMonitor, valores para
kube-prometheus-stack, Loki, Alloy, Tempo, Beyla opcional e bootstrap
OpenTelemetry na aplicação Go.

Compose e Ansible permanecem como entrega principal. Kubernetes é extensão
opcional preparada para cluster real e validada por Helm no CI.

## Aceite e verificação

- [x] Release notes v1.1.0 versionadas.
- [x] Tickets KORP-042, KORP-044, KORP-045, KORP-046 e KORP-047 concluídos.
- [ ] PR de release aberta para `main`.
- [ ] GitHub Actions verdes na PR de release.
- [ ] Tag `v1.1.0` publicada.

## Segurança, observabilidade e recuperação

OpenTelemetry é opt-in e não altera o comportamento padrão. Beyla fica opcional
por exigir permissões eBPF no cluster.

## Evidências

- PR #38 passou nos checks e foi integrada em `develop`.
- Evidências finais serão registradas após PR de release e tag.
