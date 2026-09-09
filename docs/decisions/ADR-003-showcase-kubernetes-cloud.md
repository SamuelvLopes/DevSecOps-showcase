# ADR-003 — Kubernetes e cloud como extensões opcionais

Status: aceito para implementação incremental. Data: 2026-09-08.

## Contexto e decisão

O backlog original inclui Helm, Kubernetes, Terraform e cloud. A entrega core
continua baseada em Docker Compose e Ansible porque esse é o caminho diretamente
alinhado ao enunciado. Cloud e Kubernetes entram como extensões opcionais com
aceite próprio.

A primeira extensão aceita é Terraform para VM Ubuntu em AWS e Azure. Terraform
provisiona infraestrutura e retorna outputs para o Ansible; o deploy da aplicação
continua no playbook.

## Alternativa e consequências

Criar um cluster Kubernetes completo aumentaria custo, tempo e superfície de
falha. Uma VM por Terraform prova infraestrutura como código em ambiente limpo e
preserva a simplicidade operacional do desafio.

## Critério para reconsiderar

Helm ou Kubernetes podem ser adicionados depois que a trilha de VM estiver
validada, com CI verde e documentação reproduzível.
