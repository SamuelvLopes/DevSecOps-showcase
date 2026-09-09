# KORP-037 — Clean-room validation

Status: in_review. Risco: médio. Depende de KORP-036.

## Objetivo

Validar que a entrega executa fora do diretório de trabalho principal, sem
depender de containers ativos ou arquivos temporários locais.

## Implementação e limites

`scripts/clean-checkout-validation.sh` copia a árvore do projeto para um
diretório temporário sem `.git`, executa `make check`, `make compose-config` e
`make demo`, e remove a stack ao final.

Esta validação comprova reprodutibilidade local em checkout limpo. A execução em
VM remota com Ansible permanece como evidência final antes da release.

## Aceite e verificação

- [x] Validação roda fora do diretório de trabalho principal.
- [x] Validação não depende de containers previamente ativos.
- [x] Checks Go e Compose executados no diretório temporário.
- [x] Demo HTTP/Prometheus/Grafana executada no diretório temporário.
- [x] Cleanup automático remove stack ao final.

## Segurança, observabilidade e recuperação

O script não adiciona segredos e não preserva artefatos temporários. Recuperação
por `docker compose down --remove-orphans`.

## Evidências

- `make clean-checkout`: executou em diretório temporário sem `.git`, rodou
  `make check`, `make compose-config` e `make demo`.
- Demo no diretório temporário validou contrato HTTP, portas, Prometheus e
  Grafana.
- Saída do script: `clean checkout validation passed`.
- Após a validação, `docker compose ps` no working tree principal não retornou
  containers ativos.
- Links Markdown locais válidos.
- Termos internos/proibidos ausentes em busca por palavra inteira.
- `make compose-config`: Compose válido.
- GitHub Actions: pendente após abertura da PR.
