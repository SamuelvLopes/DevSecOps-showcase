# KORP-014 — CI Quality Checks

Status: in_review. Risco: médio. Depende de KORP-002.

## Objetivo

Adicionar CI no GitHub Actions para validar qualidade Go, build da imagem e
configuração Compose em pushes e pull requests para `develop` e `main`.

## Implementação e limites

`.github/workflows/ci.yml` define os jobs `Go quality` e `Docker and Compose`.
O primeiro usa Go a partir de `app/go.mod` e roda `make check`. O segundo constrói
a imagem da aplicação e valida `compose.yaml`. Smoke completo da stack entra em
KORP-017.

## Aceite e verificação

- [x] Workflow versionado.
- [x] Pull requests para `develop` e `main` disparam CI.
- [x] Pushes para `develop` e `main` disparam CI.
- [x] Go quality executa testes, race detector, vet, gofmt e whitespace.
- [x] Docker/Compose valida build de imagem e configuração Compose.

## Segurança, observabilidade e recuperação

Workflow usa permissão `contents: read` e não depende de secrets. Recuperação por
revert do ticket.

## Evidências

- PyYAML: workflow e DAG carregaram sem erro.
- `make check`: formatação, vet, race detector, testes e whitespace passaram.
- `make docker-build`: imagem `http-server-projeto-korp:local` construída.
- `make compose-config`: arquivo Compose validado.
- Execução do GitHub Actions: pendente após abertura da PR.
