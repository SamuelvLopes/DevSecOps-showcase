# KORP-002 — Serviço HTTP obrigatório em Go

Status: in_review. Risco: médio. Depende de KORP-001.

## Objetivo

Implementar http-server-projeto-korp na porta 8080 com GET /projeto-korp,
Content-Type application/json e exatamente nome/horario. Nome deve ser Projeto
Korp; horario é UTC atual, recalculado a cada request, em RFC3339.

## Implementação e limites

Usar net/http e encoding/json, entrada em app/cmd/http-server-projeto-korp e
handler testável em app/internal. Injetar função de relógio no handler para testes
determinísticos. Rotas desconhecidas retornam 404; métodos diferentes de GET no
endpoint retornam 405 com Allow: GET. Sem Docker, métricas ou NGINX neste ticket.

## Aceite e verificação

- [x] HTTP 200, JSON com apenas os dois campos e Content-Type correto.
- [x] Relógio não UTC convertido corretamente e chamado novamente por request.
- [x] POST retorna 405/Allow; rota desconhecida retorna 404.
- [x] gofmt, go vet e go test -race -cover ./... em app/.
- [x] Execução local e curl com contrato confirmado.
- [x] Não exigir timestamps diferentes para chamadas dentro do mesmo segundo.

## Segurança, observabilidade e recuperação

Sem secrets ou dados de usuário no contrato. Timeouts/logs/shutdown serão tratados
em KORP-003 antes do container. Recuperação por revert do ticket.

## Evidências

- `make check`: formatação, vet, race detector e testes passaram.
- Pacote `internal/server`: 86,7% de cobertura.
- Binário iniciado em `127.0.0.1:18080` devido à porta 8080 já estar ocupada
  no host de desenvolvimento.
- `GET /projeto-korp`: HTTP 200 e JSON com horário UTC atual.
- `POST /projeto-korp`: HTTP 405; `GET /unknown`: HTTP 404.
