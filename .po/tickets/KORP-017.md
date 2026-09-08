# KORP-017 — Integration/smoke testing do Compose

Status: in_review. Risco: médio. Depende de KORP-007, KORP-009 e KORP-014.

## Objetivo

Adicionar smoke test automatizado para validar a stack Compose completa.

## Implementação e limites

`scripts/smoke-compose.sh` sobe a stack com `docker compose up --build -d`,
espera NGINX, Prometheus e Grafana, valida o contrato `/projeto-korp` pela porta
80, confirma Prometheus target `up`, métricas principais, datasource/dashboard
Grafana e inspeção de portas. O script derruba a stack ao sair. O workflow CI
ganha o job `Compose smoke`.

## Aceite e verificação

- [x] Smoke test versionado.
- [x] Smoke valida HTTP pela porta 80.
- [x] Smoke valida Prometheus target e métricas.
- [x] Smoke valida Grafana datasource e dashboard.
- [x] Smoke confirma app sem porta publicada e NGINX em `80:80`.
- [x] CI executa smoke após jobs básicos.

## Segurança, observabilidade e recuperação

O teste usa apenas endpoints locais e remove containers/rede no final. Volumes
nomeados podem permanecer para preservar dados locais; cleanup completo será
documentado no runbook final. Recuperação por `make compose-down`.

## Evidências

- `make check`: formatação, vet, race detector, testes e whitespace passaram.
- PyYAML: workflow CI e DAG carregaram sem erro.
- `make compose-smoke`: stack iniciada, contrato JSON validado, Prometheus
  target/query validado, Grafana datasource/dashboard validado e inspeção de
  portas confirmada.
- Saída do smoke: `compose smoke passed`.
- Após o smoke, `docker compose ps` não retornou containers ativos.
- GitHub Actions: pendente após abertura da PR.
