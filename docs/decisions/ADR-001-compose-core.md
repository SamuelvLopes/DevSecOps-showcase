# ADR-001 — Docker Compose como caminho principal

Status: aceito para implementação. Data: 2026-09-08.

## Contexto e decisão

O enunciado pede Docker Compose e provisionamento Ansible. Manteremos os quatro
serviços em um Compose na raiz, provisionado numa VM Ubuntu 24.04 LTS limpa.
Prometheus e Grafana terão configuração e dashboard versionados.

## Alternativa e consequências

Kubernetes acrescentaria orquestração, mas não substituiria o aceite de Compose
e Ansible. O core permanece single-host, sem alegação de alta disponibilidade.
O objetivo é permitir reprodução por um avaliador com poucos pré-requisitos.

## Verificação e recuperação

Provar primeiro provisionamento, curl, métricas/dashboard e segundo run sem
mudanças. Restaurar snapshot da VM permite repetir a prova de instalação limpa.
Essas verificações são futuras; este ADR não afirma execução concluída.
