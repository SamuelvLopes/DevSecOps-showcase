# KORP-035 — README, ADRs e runbook finais

Status: in_review. Risco: médio. Depende de KORP-013, KORP-015, KORP-016,
KORP-017, KORP-019, KORP-022 e KORP-034.

## Objetivo

Consolidar documentação pública para leitura e execução do desafio.

## Implementação e limites

README e matriz de requisitos foram atualizados para refletir o estado real do
core Compose, CI, segurança, carga e recuperação. `docs/runbook.md` descreve
execução local, validações, observabilidade, Ansible, recuperação, limpeza e
troubleshooting.

Este ticket não altera runtime nem pipeline.

## Aceite e verificação

- [x] README reflete o estado atual da entrega.
- [x] Matriz requisito/evidência separa itens comprovados de validação em VM
  limpa.
- [x] Runbook operacional versionado.
- [x] Links de navegação atualizados.

## Segurança, observabilidade e recuperação

Documentação reforça exposição controlada, interfaces locais de observabilidade
e comandos de recuperação.

## Evidências

- Links Markdown locais válidos.
- Termos internos/proibidos ausentes em busca por palavra inteira.
- `make check`: gofmt, go vet, race detector, testes e whitespace passaram.
- `make compose-config`: Compose válido.
- GitHub Actions: pendente após abertura da PR.
