# KORP-009 — Grafana provisionado

Status: in_review. Risco: médio. Depende de KORP-008.

## Objetivo

Adicionar Grafana ao Compose com datasource Prometheus e dashboard provisionado
por arquivos versionados.

## Implementação e limites

Grafana usa `grafana/grafana-oss:11.4.0`, publica a interface apenas em
`127.0.0.1:3000`, provisiona datasource Prometheus em
`grafana/provisioning/datasources/prometheus.yml` e carrega o dashboard
`grafana/dashboards/projeto-korp.json`. O acesso anonimo local fica como Viewer
para facilitar a demonstracao; a senha admin pode ser alterada via
`GRAFANA_ADMIN_PASSWORD`.

## Aceite e verificação

- [x] Grafana configurado no Compose.
- [x] Datasource Prometheus provisionado.
- [x] Dashboard versionado e provisionado.
- [x] Painel de disponibilidade usa `projeto_korp_up`.
- [x] Painel de volume usa `projeto_korp_http_requests_total`.
- [x] Interface administrativa publicada apenas em loopback.

## Segurança, observabilidade e recuperação

Grafana fica restrito ao loopback do host. A senha padrão é apenas fallback local
e deve ser sobrescrita por `GRAFANA_ADMIN_PASSWORD` em ambientes compartilhados.
Recuperação por `make compose-down`; volumes persistentes são removidos apenas
manualmente.

## Evidências

- `make check`: formatação, vet, race detector, testes e whitespace passaram.
- `make compose-config`: arquivo Compose validado.
- `make compose-up`: app, NGINX, Prometheus e Grafana iniciados.
- `GET /api/health`: database `ok`, versão `11.4.0`.
- Datasource `Prometheus`: tipo `prometheus`, URL `http://prometheus:9090`,
  default `true`, UID `prometheus`.
- Dashboard `Projeto Korp`: UID `projeto-korp`, pasta `Projeto Korp`.
- Painéis carregados: `Disponibilidade da aplicacao` e `Volume de requisicoes`.
- `docker inspect grafana`: `3000/tcp` publicado em `127.0.0.1:3000`,
  provisioning e dashboards montados read-only e volume `devsecops_grafana-data`.
- `make compose-down`: containers e rede removidos, preservando volumes.
