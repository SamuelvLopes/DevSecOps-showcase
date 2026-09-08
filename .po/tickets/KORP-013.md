# KORP-013 — Validação e idempotência Ansible

Status: in_review. Risco: alto. Depende de KORP-012.

## Objetivo

Adicionar validações funcionais ao playbook para comprovar HTTP pelo NGINX,
scrape Prometheus, dashboard Grafana e resposta impressa no final da execução.

## Implementação e limites

A role `validate` espera o endpoint `/projeto-korp`, valida o contrato JSON,
imprime a resposta, confirma Prometheus pronto, target `http-server-projeto-korp`
em `up`, queries `projeto_korp_up` e `projeto_korp_http_requests_total`, Grafana
saudável, datasource Prometheus e dashboard `projeto-korp`. Tasks de validação
usam `changed_when: false`; a convergência Compose também não marca mudança por
saída textual de build cacheado.

## Aceite e verificação

- [x] Playbook valida HTTP 200 pela porta 80.
- [x] Playbook valida JSON com chaves exatas `nome` e `horario`.
- [x] Playbook imprime a resposta de `/projeto-korp`.
- [x] Playbook valida Prometheus target `up`.
- [x] Playbook valida métricas de disponibilidade e volume.
- [x] Playbook valida Grafana health, datasource e dashboard.
- [x] Tasks de validação não alteram estado.

## Segurança, observabilidade e recuperação

Validações consultam endpoints locais do host alvo e não registram credenciais.
Recuperação por `docker compose down` no host alvo ou revert do ticket.

## Evidências

- `make check`: formatação, vet, race detector, testes e whitespace passaram.
- `make compose-config`: arquivo Compose validado.
- PyYAML: `site.yml`, `requirements.yml`, `group_vars/korp.yml` e tasks das
  roles carregaram sem erro.
- `ansible-playbook --syntax-check`: não executado localmente porque Ansible não
  está no PATH e `python3-venv` não está disponível para criar venv temporário.
- Execução em VM limpa: pendente para ambiente alvo.
