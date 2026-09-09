# KORP-007 — NGINX reverse proxy

Status: done. Risco: médio. Depende de KORP-006.

## Objetivo

Adicionar NGINX oficial como ponto de entrada HTTP na porta 80, encaminhando
requisições para a aplicação em `app:8080`.

## Implementação e limites

`nginx/http-server-projeto-korp.conf` define o servidor na porta 80 e encaminha
para o serviço `app` pelo DNS da rede Docker. O Compose usa a imagem oficial
`nginx:1.27-alpine`, publica `80:80` e monta `./nginx` em `/etc/nginx/conf.d:ro`.
A aplicação continua sem porta publicada no host.

## Aceite e verificação

- [x] Arquivo `http-server-projeto-korp.conf` versionado.
- [x] NGINX oficial configurado no Compose.
- [x] Host publica apenas NGINX em `80:80`.
- [x] Aplicação continua sem `ports`.
- [x] `GET /projeto-korp` funciona pela porta 80.
- [x] `nginx -t` passa dentro do container.

## Segurança, observabilidade e recuperação

Configuração montada somente leitura. A porta 8080 permanece acessível apenas na
rede Docker. Recuperação por `make compose-down` ou revert do ticket.

## Evidências

- `make check`: formatação, vet, race detector, testes e whitespace passaram.
- `make compose-config`: arquivo Compose validado.
- `make compose-up`: app e NGINX iniciados.
- `nginx -t`: configuração válida dentro do container.
- `GET /projeto-korp` pela porta 80: HTTP 200 e JSON com horário UTC atual.
- `GET /metrics` pela porta 80: expôs `projeto_korp_up 1` e contadores HTTP.
- `docker inspect app`: `Ports={"8080/tcp":null}`.
- `docker inspect nginx`: `80/tcp` publicado em `0.0.0.0:80` e volume
  `/etc/nginx/conf.d` montado somente leitura.
- `make compose-down`: containers e rede removidos.
- [PR #7](https://github.com/SamuelvLopes/DevSecOps-showcase/pull/7) mesclada em develop.
