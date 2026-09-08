# KORP-004 — Métricas Prometheus da aplicação

Status: done. Risco: médio. Depende de KORP-003.

## Objetivo

Expor métricas Prometheus na aplicação para disponibilidade e volume de
requisições, preparando o scrape que será configurado nos tickets de
infraestrutura.

## Implementação e limites

`GET /metrics` expõe texto Prometheus 0.0.4. A aplicação publica
`projeto_korp_up` e `projeto_korp_http_requests_total` com labels controladas
por rota conhecida, método e status. Rotas desconhecidas usam o label `unknown`
para evitar cardinalidade baseada em URLs arbitrárias. Não há dependência externa
de biblioteca Prometheus neste ticket.

## Aceite e verificação

- [x] `GET /metrics` retorna texto Prometheus.
- [x] Métrica de disponibilidade `projeto_korp_up` exposta.
- [x] Contador de volume HTTP incrementa por rota/método/status.
- [x] Labels de rota possuem cardinalidade controlada.
- [x] Outros métodos em `/metrics` retornam 405 com `Allow: GET`.
- [x] Contrato de `/projeto-korp` preservado pelos testes existentes.

## Segurança, observabilidade e recuperação

Métricas não incluem query string, IP, user-agent, corpo ou valores de usuário.
Recuperação por revert do ticket.

## Evidências

- `make check`: formatação, vet, race detector, testes e whitespace passaram.
- Pacote `internal/metrics`: 96,1% de cobertura.
- Binário iniciado na porta padrão 8080.
- `GET /projeto-korp`: HTTP 200 e JSON com horário UTC atual.
- `GET /metrics`: expôs `projeto_korp_up 1`.
- `GET /metrics`: expôs contador para `/projeto-korp`, método GET e status 200.
- [PR #4](https://github.com/SamuelvLopes/DevSecOps-showcase/pull/4) mesclada em develop.
