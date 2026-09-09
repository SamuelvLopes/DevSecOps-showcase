# KORP-005 — Dockerfile multi-stage e hardening da imagem

Status: done. Risco: médio. Depende de KORP-004.

## Objetivo

Adicionar Dockerfile para build e execução do `http-server-projeto-korp`,
mantendo porta 8080 e reduzindo superfície de runtime.

## Implementação e limites

O Dockerfile fica em `app/Dockerfile`, usa build multi-stage com Go e imagem
final `scratch`. O binário é compilado sem CGO, com `-trimpath` e símbolos
removidos. O runtime usa usuário numérico não-root `65532:65532` e expõe 8080.
Compose e NGINX entram nos tickets seguintes.

## Aceite e verificação

- [x] Dockerfile multi-stage versionado.
- [x] Imagem final sem shell e sem gerenciador de pacotes.
- [x] Runtime não-root.
- [x] Container escuta em 8080.
- [x] `GET /projeto-korp`, `/health` e `/metrics` funcionam no container.

## Segurança, observabilidade e recuperação

Imagem final contém apenas o binário da aplicação. Sem secrets, credenciais ou
arquivos locais copiados para o runtime. Recuperação por revert do ticket.

## Evidências

- `make check`: formatação, vet, race detector, testes e whitespace passaram.
- `make docker-build`: imagem `http-server-projeto-korp:local` construída.
- Container publicado localmente em `127.0.0.1:8080`.
- `GET /projeto-korp`: HTTP 200 e JSON com horário UTC atual.
- `GET /health`: HTTP 204 sem corpo.
- `GET /metrics`: expôs `projeto_korp_up 1` e contador HTTP.
- `docker inspect`: `User=65532:65532` e `ExposedPorts={"8080/tcp":{}}`.
- [PR #5](https://github.com/SamuelvLopes/DevSecOps-showcase/pull/5) mesclada em develop.
