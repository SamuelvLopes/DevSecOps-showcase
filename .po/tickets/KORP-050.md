# KORP-050 — Nomenclatura literal do container e criação explícita da rede

Status: in_review. Risco: baixo. Depende de KORP-006 e KORP-012.

## Objetivo

Fechar duas lacunas de aderência literal ao enunciado, sem alterar o
comportamento validado da stack:

1. o enunciado nomeia o "Container 1: http-server-projeto-korp", mas o
   container efetivo era `devsecops-app-1` (apenas a imagem carregava o nome);
2. o enunciado lista "criação da rede Docker" como item do playbook, e a rede
   era criada apenas de forma implícita pelo Compose.

## Implementação

- `compose.yaml` recebe `name: projeto-korp` no topo, fixando o nome do projeto
  e tornando determinísticos os labels aplicados aos recursos.
- Serviço `app` recebe `container_name: http-server-projeto-korp`.
  O nome do serviço permanece `app`, preservando o alias DNS usado por
  `nginx/http-server-projeto-korp.conf` e por `prometheus/prometheus.yml`.
- `ansible/roles/stack` passa a criar a rede explicitamente com
  `community.docker.docker_network`, guardada por `docker_network_info` para
  ser idempotente por construção, seguida de validação do driver `bridge`.
- `ansible/group_vars/korp.yml` centraliza `korp_network_name`,
  `korp_compose_project` e `korp_network_labels`.

## Compatibilidade entre Ansible e Compose

Uma rede pré-criada sem os labels de identidade do Compose faz o converge
falhar com `network projeto-korp was found but has incorrect label
com.docker.compose.network`. A task aplica os dois labels de identidade
(`com.docker.compose.network` e `com.docker.compose.project`); `config-hash` e
`version` não são exigidos pelo Compose e ficam fora, por serem detalhes
internos e voláteis.

Fixar `name: projeto-korp` no Compose é o que torna
`com.docker.compose.project` previsível: sem isso o valor derivaria do nome do
diretório, divergindo entre o checkout local e `/opt/projeto-korp` no host
provisionado.

## Aceite

- [x] `docker compose ps` mostra o container `http-server-projeto-korp`.
- [x] Container da aplicação continua sem porta publicada no host.
- [x] Alias `app` continua resolvendo dentro da rede.
- [x] `curl http://localhost:80/projeto-korp` retorna o contrato esperado.
- [x] `scripts/smoke-compose.sh` passa.
- [x] `scripts/recovery-demo.sh` passa.
- [x] Converge do Compose funciona sobre rede pré-criada pela task.
- [ ] Playbook executado em VM limpa com segundo run sem alterações.

## Verificação

```bash
docker compose config -q
sh scripts/smoke-compose.sh
sh scripts/recovery-demo.sh
```

Compatibilidade da rede pré-criada:

```bash
docker network create --driver bridge \
  --label com.docker.compose.network=projeto-korp \
  --label com.docker.compose.project=projeto-korp \
  projeto-korp
docker compose -f compose.yaml up --build -d
curl -fsS http://localhost/projeto-korp
```

## Segurança e recuperação

Sem impacto em superfície de exposição: o hardening do serviço e o bind das
interfaces administrativas em loopback permanecem inalterados. Reversão é o
revert do commit; a rede remanescente pode ser removida com
`docker network rm projeto-korp`.
