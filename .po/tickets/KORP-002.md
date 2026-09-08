# KORP-002 — Serviço HTTP obrigatório em Go

Status: planned. Risco: médio. Depende de KORP-001.

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

- HTTP 200, JSON com apenas os dois campos e Content-Type correto.
- Relógio não UTC convertido corretamente e chamado novamente por request.
- POST retorna 405/Allow; rota desconhecida retorna 404.
- gofmt, go vet e go test -race -cover ./... em app/.
- Execução local e curl com contrato confirmado; documentar comando e resultado.
- Não exigir timestamps diferentes para chamadas dentro do mesmo segundo.

## Segurança, observabilidade e recuperação

Sem secrets ou dados de usuário no contrato. Timeouts/logs/shutdown serão tratados
em KORP-003 antes do container. Recuperação por revert do ticket.
