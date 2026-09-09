# KORP-039 — Ensaio técnico/oral

Status: in_review. Risco: baixo. Depende de KORP-037.

## Objetivo

Versionar um walkthrough técnico para sustentar a apresentação da entrega.

## Implementação e limites

`docs/technical-walkthrough.md` descreve abertura, fluxo principal, escolhas
técnicas, comandos de demonstração e perguntas prováveis com respostas objetivas.
O smoke Compose também passou a aguardar o target Prometheus com retry, evitando
falha por scrape ainda pendente em ambientes mais lentos.

Este ticket não altera runtime.

## Aceite e verificação

- [x] Walkthrough técnico versionado.
- [x] Escolhas principais explicadas.
- [x] Perguntas prováveis cobertas.
- [x] Próximos passos antes da release explicitados.
- [x] Smoke test robustecido para aguardar target Prometheus saudável.

## Segurança, observabilidade e recuperação

O walkthrough referencia threat model, observabilidade e recuperação sem
adicionar novos controles.

## Evidências

- Links Markdown locais válidos.
- Termos internos/proibidos ausentes em busca por palavra inteira.
- `make compose-smoke`: contrato HTTP, Prometheus, Grafana e portas validados.
- `make check`: gofmt, go vet, race detector, testes e whitespace passaram.
- `make compose-config`: Compose válido.
- GitHub Actions: pendente após abertura da PR.
