# KORP-016 — Dependabot e governance GitHub

Status: done. Risco: baixo. Depende de KORP-014.

## Objetivo

Adicionar automação de atualização de dependências e documentar governança
recomendada para branches e checks obrigatórios.

## Implementação e limites

`.github/dependabot.yml` agenda atualizações semanais para Go modules,
Dockerfile, Compose e GitHub Actions. `docs/github-governance.md` documenta
proteções recomendadas para `main` e `develop`, incluindo PR obrigatório, checks,
conversas resolvidas e bloqueio de force push/deleção. Configuração remota de
branch protection não é versionável neste repositório.

## Aceite e verificação

- [x] Dependabot versionado.
- [x] Go modules monitorado.
- [x] Dockerfile monitorado.
- [x] Compose monitorado.
- [x] GitHub Actions monitorado.
- [x] Governança de branches e checks documentada.

## Segurança, observabilidade e recuperação

Dependabot não usa secrets. Proteções recomendadas reduzem merge sem revisão e
sem checks. Recuperação por revert do ticket.

## Evidências

- PyYAML: Dependabot, workflow e DAG carregaram sem erro.
- `make check`: formatação, vet, race detector, testes e whitespace passaram.
- `make compose-config`: arquivo Compose validado.
- Documentação GitHub consultada: `docker-compose` é ecossistema suportado pelo
  Dependabot.
- GitHub Actions na PR #15: `Go quality`, `Docker and Compose`, security gates e
  `GitGuardian Security Checks` passaram.
- [PR #15](https://github.com/SamuelvLopes/DevSecOps-showcase/pull/15) mesclada em develop.
