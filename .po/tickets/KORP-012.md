# KORP-012 — Provisionamento total por Ansible

Status: in_review. Risco: alto. Depende de KORP-011.

## Objetivo

Implementar o playbook que prepara um host Linux, instala Docker/Compose,
transfere os artefatos da stack e converge os serviços com Docker Compose.

## Implementação e limites

A role `docker` instala pacotes base, configura o repositório oficial Docker,
instala Docker Engine, Buildx e Compose plugin, e garante o serviço ativo. A role
`stack` cria `/opt/projeto-korp`, copia aplicação, Compose, NGINX, Prometheus e
Grafana, e executa `docker compose up --build -d`. A validação funcional completa
fica em KORP-013.

## Aceite e verificação

- [x] Docker instalado a partir do repositório oficial.
- [x] Compose plugin instalado.
- [x] Diretório de deploy criado.
- [x] Artefatos necessários copiados para o host alvo.
- [x] Stack convergida com `docker compose up --build -d`.
- [x] Sem credenciais versionadas.

## Segurança, observabilidade e recuperação

O playbook usa sudo apenas no host alvo. Configurações administrativas continuam
restritas a loopback pelo Compose. Recuperação por `docker compose down` no host
alvo ou revert do ticket.

## Evidências

- `make check`: formatação, vet, race detector, testes e whitespace passaram.
- `make compose-config`: arquivo Compose validado.
- PyYAML: `site.yml`, `requirements.yml`, `group_vars/korp.yml` e tasks das
  roles carregaram sem erro.
- Execução em VM limpa: pendente para KORP-013.
