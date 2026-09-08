# GitHub governance

## Branches

- `main`: release estável.
- `develop`: integração contínua dos tickets.
- `feature/KORP-XXX-descricao`: trabalho por ticket, com PR para `develop`.

## Proteções recomendadas

Aplicar em `main` e `develop`:

- exigir pull request antes de merge;
- exigir branch atualizada antes de merge;
- exigir resolução de conversas;
- bloquear force push e deleção;
- exigir os checks `Go quality`, `Docker and Compose`,
  `Go vulnerability scan`, `Image vulnerability scan` e
  `GitGuardian Security Checks`.

## Dependências

Dependabot cria PRs semanais para Go, Dockerfile, Compose e GitHub Actions. PRs
de dependência seguem os mesmos checks de qualidade e segurança.
