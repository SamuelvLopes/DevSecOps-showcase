# KORP-044 — kube-prometheus-stack e ServiceMonitor

Status: done. Risco: médio. Depende de KORP-042.

## Objetivo

Adicionar observabilidade Kubernetes de métricas com Prometheus via
`kube-prometheus-stack` e descoberta do serviço por `ServiceMonitor`.

## Implementação e limites

A stack deve ser opcional e instalada por Helm. O chart da aplicação deve expor
labels/annotations compatíveis com `ServiceMonitor` para coletar `/metrics`.

## Aceite e verificação

- [x] Valores Helm para instalar `kube-prometheus-stack`.
- [x] `ServiceMonitor` da aplicação.
- [x] Consulta para `projeto_korp_up` documentada.
- [x] CI valida `helm lint`/`helm template`.

## Segurança, observabilidade e recuperação

Grafana e Prometheus não devem ser expostos publicamente por padrão. Acesso
externo deve usar port-forward ou túnel.

## Evidências

- `charts/observability/kube-prometheus-stack-values.yaml` versionado.
- `docs/kubernetes-observability.md` documenta instalação e consulta PromQL.
