# KORP-006 — Docker Compose e runtime hardening

Status: done. Risco: médio. Depende de KORP-005.

## Objetivo

Adicionar Docker Compose para executar a aplicação em rede bridge explícita,
sem publicar a porta 8080 no host.

## Implementação e limites

`compose.yaml` define o serviço `app`, constrói a imagem local da aplicação,
expõe 8080 apenas para a rede Docker e conecta o container à rede bridge
`projeto-korp`. O runtime usa `read_only`, `cap_drop: ALL` e
`no-new-privileges:true`. A publicação no host será feita pelo NGINX no próximo
ticket.

## Aceite e verificação

- [x] Compose versionado na raiz.
- [x] Rede bridge `projeto-korp` configurada.
- [x] Serviço da aplicação sem `ports`.
- [x] Aplicação responde na rede bridge em 8080.
- [x] Hardening básico de runtime configurado.

## Segurança, observabilidade e recuperação

A porta da aplicação não fica publicada no host. O container não recebe
capabilities adicionais e roda com filesystem somente leitura. Recuperação por
`make compose-down` ou revert do ticket.

## Evidências

- `make check`: formatação, vet, race detector, testes e whitespace passaram.
- `make compose-config`: arquivo Compose validado.
- `make compose-up`: imagem construída e serviço iniciado.
- Rede `projeto-korp` criada com driver bridge.
- `GET /projeto-korp`: HTTP 200 e JSON com horário UTC atual via IP interno.
- `GET /metrics`: expôs `projeto_korp_up 1` e contadores HTTP.
- `docker inspect`: `Ports={"8080/tcp":null}`, `ReadOnly=true`,
  `CapDrop=["ALL"]`, `SecurityOpt=["no-new-privileges:true"]`.
- `make compose-down`: container e rede removidos.
- [PR #6](https://github.com/SamuelvLopes/DevSecOps-showcase/pull/6) mesclada em develop.
