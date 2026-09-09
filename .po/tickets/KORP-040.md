# KORP-040 — Release final e envio

Status: in_review. Risco: médio. Depende de KORP-037 e KORP-039.

## Objetivo

Preparar release final do desafio para `main`.

## Implementação e limites

`RELEASE.md` consolida escopo, validações locais, validações remotas, execução
rápida, demo e provisionamento. A branch `release/v1.0.0` será integrada em
`main` por PR.

## Aceite e verificação

- [x] Release notes versionadas.
- [x] Estado dos tickets atualizado.
- [x] Documentação aponta para execução, demo e runbook.
- [x] PR de release preparada para `main`.

## Segurança, observabilidade e recuperação

A release mantém os gates de segurança e validações automatizadas já integrados
em `develop`.

## Evidências

- Links Markdown locais válidos.
- Termos internos/proibidos ausentes em busca por palavra inteira.
- `make check`: gofmt, go vet, race detector, testes e whitespace passaram.
- `make compose-config`: Compose válido.
- `make clean-checkout`: executou `make check`, `make compose-config` e
  `make demo` em diretório temporário.
- Demo no diretório temporário validou contrato HTTP, portas, Prometheus e
  Grafana.
- Após validação, `docker compose ps` não retornou containers ativos.
- GitHub Actions: pendente após abertura da PR de release.
