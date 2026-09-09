# KORP-003 — Operabilidade da aplicação

Status: done. Risco: baixo. Depende de KORP-002.

## Objetivo

Adicionar comportamento operacional básico ao serviço antes da containerização:
timeouts HTTP, logs estruturados, encerramento gracioso e health check local.

## Implementação e limites

O endpoint funcional `/projeto-korp` permanece sem alteração de contrato.
`/health` responde 204 para GET e 405 para outros métodos. O servidor usa
timeouts explícitos e trata SIGINT/SIGTERM com shutdown gracioso. Readiness
separado fica fora deste ticket porque a aplicação não possui dependência externa.

## Aceite e verificação

- [x] Endereço padrão continua `:8080`.
- [x] Timeouts HTTP configurados de forma explícita.
- [x] Logs em JSON no start e no shutdown.
- [x] Health check `GET /health` retorna 204 sem corpo.
- [x] SIGINT/SIGTERM acionam shutdown gracioso.
- [x] Contrato de `/projeto-korp` preservado pelos testes existentes.

## Segurança, observabilidade e recuperação

Logs não registram corpo de requisição nem dados de usuário. O health check não
expõe detalhes internos. Recuperação por revert do ticket.

## Evidências

- `make check`: formatação, vet, race detector, testes e whitespace passaram.
- Pacote `internal/server`: 90,5% de cobertura.
- Binário iniciado na porta padrão 8080.
- `GET /projeto-korp`: HTTP 200 e JSON com horário UTC atual.
- `GET /health`: HTTP 204 sem corpo.
- `SIGTERM`: log de shutdown emitido e processo encerrado sem erro.
- [PR #3](https://github.com/SamuelvLopes/DevSecOps-showcase/pull/3) mesclada em develop.
