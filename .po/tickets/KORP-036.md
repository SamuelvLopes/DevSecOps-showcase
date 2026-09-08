# KORP-036 — Demo script e evidências

Status: in_review. Risco: baixo. Depende de KORP-035.

## Objetivo

Versionar roteiro de demo e script de evidências para apresentação técnica.

## Implementação e limites

`scripts/demo-evidence.sh` sobe a stack, valida contrato HTTP, imprime serviços
e portas, consulta Prometheus e verifica datasource/dashboard do Grafana.
`docs/demo.md` descreve a sequência recomendada de apresentação.

O script não grava artefatos permanentes no repositório.

## Aceite e verificação

- [x] Script de evidência versionado.
- [x] Roteiro de demo versionado.
- [x] Script remove a stack no fim.
- [x] Links de navegação atualizados.

## Segurança, observabilidade e recuperação

O script valida exposição por NGINX, Prometheus e Grafana sem adicionar portas ou
segredos.

## Evidências

- `make demo`: contrato HTTP válido, portas publicadas impressas, Prometheus
  `up{job="http-server-projeto-korp"} = 1`, volume de requisições e
  datasource/dashboard Grafana validados.
- Saída do script: `demo evidence passed`.
- Após a demo, `docker compose ps` não retornou containers ativos.
- Links Markdown locais válidos.
- Termos internos/proibidos ausentes em busca por palavra inteira.
- `make check`: gofmt, go vet, race detector, testes e whitespace passaram.
- `make compose-config`: Compose válido.
- GitHub Actions: pendente após abertura da PR.
