# KORP-008 — Prometheus

Status: in_review. Risco: médio. Depende de KORP-004 e KORP-006.

## Objetivo

Adicionar Prometheus ao Compose para coletar as métricas da aplicação e validar
disponibilidade de scrape e volume de requisições.

## Implementação e limites

`prometheus/prometheus.yml` configura o job `http-server-projeto-korp` com target
`app:8080` e path `/metrics`. O serviço usa a imagem `prom/prometheus:v2.55.1`,
porta administrativa publicada apenas em `127.0.0.1:9090` e volume
`prometheus-data` para persistência. Grafana entra no próximo ticket.

## Aceite e verificação

- [x] Prometheus configurado no Compose.
- [x] Configuração versionada em `prometheus/prometheus.yml`.
- [x] Target `app:8080` fica `up`.
- [x] Métrica `projeto_korp_up` consultável pelo Prometheus.
- [x] Métrica `projeto_korp_http_requests_total` consultável pelo Prometheus.
- [x] Dados persistem em volume nomeado.

## Segurança, observabilidade e recuperação

Prometheus fica acessível apenas via loopback do host. Configuração montada
somente leitura. Recuperação por `make compose-down`; volumes persistentes são
removidos apenas manualmente.

## Evidências

- `make check`: formatação, vet, race detector, testes e whitespace passaram.
- `make compose-config`: arquivo Compose validado.
- `make compose-up`: app, NGINX e Prometheus iniciados.
- Target ativo `http://app:8080/metrics`: health `up`.
- Query `projeto_korp_up`: retornou valor `1`.
- Query `projeto_korp_http_requests_total`: retornou contadores para `/health`
  status 204 e `/projeto-korp` status 200.
- `docker inspect prometheus`: `9090/tcp` publicado em `127.0.0.1:9090`,
  configuração montada read-only e volume `devsecops_prometheus-data`.
- `make compose-down`: containers e rede removidos, preservando volume.
