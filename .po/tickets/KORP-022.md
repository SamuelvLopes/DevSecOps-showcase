# KORP-022 — k6 e observabilidade sob carga

Status: in_review. Risco: médio. Depende de KORP-009 e KORP-017.

## Objetivo

Executar carga curta no endpoint obrigatório e validar que o volume aparece no
Prometheus.

## Implementação e limites

`scripts/load-k6.js` executa 4 usuários virtuais por 20 segundos contra
`/projeto-korp`, validando status, nome do projeto e horário UTC. O script
`scripts/load-observability.sh` sobe a stack, executa k6 via container, aguarda
scrape do Prometheus e consulta o contador `projeto_korp_http_requests_total`.

O teste é curto e serve como evidência funcional de observabilidade. Não é um
benchmark de capacidade.

## Aceite e verificação

- [x] Carga curta versionada.
- [x] Validação do contrato HTTP durante a carga.
- [x] Consulta Prometheus confirma volume observado.
- [x] Target incorporado ao Makefile.
- [x] Job de CI executa o cenário.

## Segurança, observabilidade e recuperação

O teste usa a stack local e remove containers no fim. Recuperação por
`docker compose down --remove-orphans`.

## Evidências

- `make compose-load`: 80 requisições, 0 falhas, checks k6 100%,
  `http_req_duration p(95)=826.99µs`.
- Consulta Prometheus confirmou `observed projeto-korp requests: 80`.
- Após o teste, `docker compose ps` não retornou containers ativos.
- GitHub Actions: pendente após abertura da PR.
