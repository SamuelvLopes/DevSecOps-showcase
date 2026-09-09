# KORP-044 — kube-prometheus-stack e ServiceMonitor

Status: planned. Risco: médio. Depende de KORP-042.

## Objetivo

Adicionar observabilidade Kubernetes de métricas com Prometheus via
`kube-prometheus-stack` e descoberta do serviço por `ServiceMonitor`.

## Implementação e limites

A stack deve ser opcional e instalada por Helm. O chart da aplicação deve expor
labels/annotations compatíveis com `ServiceMonitor` para coletar `/metrics`.

## Aceite e verificação

- [ ] Valores Helm para instalar `kube-prometheus-stack`.
- [ ] `ServiceMonitor` da aplicação.
- [ ] Dashboard ou instrução de consulta para `projeto_korp_up`.
- [ ] CI valida `helm lint`/`helm template`.

## Segurança, observabilidade e recuperação

Grafana e Prometheus não devem ser expostos publicamente por padrão. Acesso
externo deve usar port-forward ou túnel.

## Evidências

Pendentes para a implementação do ticket.
