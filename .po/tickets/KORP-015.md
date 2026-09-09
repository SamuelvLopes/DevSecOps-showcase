# KORP-015 — DevSecOps security gates

Status: done. Risco: médio. Depende de KORP-014 e KORP-005.

## Objetivo

Adicionar gates de segurança automatizados para vulnerabilidades Go e imagem
Docker.

## Implementação e limites

`.github/workflows/security.yml` executa em pull requests e pushes para
`develop` e `main`. O job `Go vulnerability scan` instala e executa
`govulncheck ./...` em `app/`. O job `Image vulnerability scan` constrói a imagem
local e executa Trivy contra `http-server-projeto-korp:local`, bloqueando
vulnerabilidades HIGH e CRITICAL não corrigidas. SAST mais amplo e threat model
entram nos tickets próprios.

## Aceite e verificação

- [x] Workflow de segurança versionado.
- [x] Pull requests para `develop` e `main` disparam security gates.
- [x] Pushes para `develop` e `main` disparam security gates.
- [x] `govulncheck` cobre código Go.
- [x] Trivy cobre imagem Docker final.
- [x] Workflow não usa secrets.

## Segurança, observabilidade e recuperação

Permissões do workflow limitadas a `contents: read`. Recuperação por revert do
ticket.

## Evidências

- PyYAML: workflow e DAG carregaram sem erro.
- `make check`: formatação, vet, race detector, testes e whitespace passaram.
- `make docker-build`: imagem `http-server-projeto-korp:local` construída com
  builder Go 1.27.
- `govulncheck ./...`: nenhum achado.
- Trivy local encontrou vulnerabilidades HIGH na stdlib do binário construído
  com Go 1.24; builder atualizado para Go 1.27.
- Trivy local na imagem reconstruída com Go 1.27: nenhum HIGH/CRITICAL corrigível.
- GitHub Actions na PR #14: `Go vulnerability scan`, `Image vulnerability scan`,
  `Go quality`, `Docker and Compose` e `GitGuardian Security Checks` passaram.
- [PR #14](https://github.com/SamuelvLopes/DevSecOps-showcase/pull/14) mesclada em develop.
