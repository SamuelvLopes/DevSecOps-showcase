# KORP-061 — Release v1.2.2 chart Kubernetes validado

Status: in_review. Risco: baixo. Depende de KORP-060.

## Objetivo

Promover para `main` o ajuste do chart Kubernetes validado em cluster real.

## Escopo

- NGINX do chart passa a usar imagem unprivileged.
- Configuração do NGINX no chart passa a escutar porta alta compatível com execução sem capabilities.
- README registra o escopo real das extensões sem alterar o core Compose/Ansible.

## Aceite

- [x] KORP-060 integrado em `develop`.
- [ ] PR de release aberta para `main`.
- [ ] GitHub Actions verdes na PR de release.
- [ ] Tag `v1.2.2` publicada.

## Evidências

- PR #61 passou em todos os checks e foi integrada em `develop`.
- KORP-060 registra validação em microk8s com app e NGINX em execução, endpoint `/projeto-korp` respondendo e métricas expostas.
