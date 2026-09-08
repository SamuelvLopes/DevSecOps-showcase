# ADR-003 — Kubernetes e cloud como extensões futuras

Status: aceito para implementação. Data: 2026-09-08.

## Contexto e decisão

O backlog original inclui Helm, Kubernetes, Terraform e cloud. A entrega atual
prioriza requisitos oficiais, qualidade, segurança, automação e evidências.
Essas extensões ficam adiadas e não bloqueiam a versão final do core.

## Alternativa e consequências

Implementar todas as trilhas aumentaria amplitude e tempo de validação. A escolha
atual concentra esforço em validar o provisionamento e a operação do core.

## Critério para reconsiderar

Core validado em VM limpa, CI verde e documentação reproduzível. Uma extensão
deve ter objetivo, aceite e evidência próprios.
