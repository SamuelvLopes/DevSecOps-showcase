# KORP-019 — Security code review e PR checklist

Status: in_review. Risco: médio. Depende de KORP-018.

## Objetivo

Registrar revisão de segurança do core Compose e reforçar o template de PR com
um checklist mínimo para mudanças futuras.

## Implementação e limites

`docs/security-review.md` consolida controles verificados, evidências e
pendências aceitas antes da release. O template de PR passa a exigir verificação
explícita de portas, segredos, logs/métricas, permissões e riscos.

Este ticket não altera runtime, pipeline ou infraestrutura.

## Aceite e verificação

- [x] Revisão de segurança documentada.
- [x] Controles existentes relacionados a evidências versionadas.
- [x] Pendências antes da release registradas.
- [x] Template de PR com checklist de segurança.

## Segurança, observabilidade e recuperação

A mudança reduz risco de regressão em PRs posteriores. Recuperação por revert do
ticket.

## Evidências

- Revisão estática dos arquivos de app, Dockerfile, Compose, NGINX, Ansible e
  GitHub Actions.
