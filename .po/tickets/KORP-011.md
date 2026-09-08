# KORP-011 — Estrutura Ansible

Status: in_review. Risco: médio. Depende de KORP-007 e KORP-009.

## Objetivo

Criar a estrutura Ansible que será usada para provisionar Docker, publicar a
stack Compose e executar validações automatizadas nos tickets seguintes.

## Implementação e limites

`ansible/site.yml` define o play principal para o grupo `korp`, com roles
`docker`, `stack` e `validate`. `ansible/ansible.cfg`, inventário local,
inventário exemplo, variáveis de grupo e `requirements.yml` ficam versionados.
As roles possuem placeholders explícitos; instalação Docker, deploy e validação
funcional entram em KORP-012 e KORP-013.

## Aceite e verificação

- [x] Estrutura Ansible versionada.
- [x] Inventário exemplo para VM remota criado.
- [x] Inventário local para validação estrutural criado.
- [x] Variáveis centrais de caminho e URLs documentadas.
- [x] Roles planejadas separadas por responsabilidade.
- [x] Makefile possui alvo de syntax check.

## Segurança, observabilidade e recuperação

Nenhuma credencial é versionada. Inventário real pode ser ajustado localmente.
Recuperação por revert do ticket.

## Evidências

- `make check`: formatação, vet, race detector, testes e whitespace passaram.
- `make compose-config`: arquivo Compose validado.
- PyYAML: `site.yml`, `requirements.yml`, `group_vars/korp.yml` e tasks das
  roles carregaram sem erro.
- `ansible-playbook --version`: indisponível no PATH local nesta etapa.
