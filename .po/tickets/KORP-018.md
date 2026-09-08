# KORP-018 — Threat Modeling STRIDE

Status: in_review. Risco: médio. Depende de KORP-007 e KORP-009.

## Objetivo

Documentar threat model STRIDE para o core Compose e relacionar ameaças,
controles implementados e pendências.

## Implementação e limites

`docs/threat-model.md` descreve escopo, ativos, limites de confiança, ameaças
STRIDE, controles existentes, riscos aceitos e verificações. O documento cobre
NGINX, aplicação Go, Prometheus, Grafana, Docker/Compose, Ansible e GitHub
Actions. Não adiciona novos controles de runtime neste ticket.

## Aceite e verificação

- [x] Escopo documentado.
- [x] Ativos documentados.
- [x] Limites de confiança documentados.
- [x] STRIDE coberto em tabela.
- [x] Controles implementados e pendências separados.
- [x] Riscos aceitos documentados.

## Segurança, observabilidade e recuperação

O documento orienta revisão final e próximos tickets de segurança. Recuperação
por revert do ticket.

## Evidências

- `make check`: formatação, vet, race detector, testes e whitespace passaram.
- `make compose-smoke`: contrato HTTP, Prometheus, Grafana e portas validados.
- Revisão de links Markdown locais: todos válidos.
- Após o smoke, `docker compose ps` não retornou containers ativos.
