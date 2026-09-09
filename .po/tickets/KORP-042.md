# KORP-042 — Helm chart da aplicação

Status: planned. Risco: médio. Depende de KORP-041.

## Objetivo

Adicionar um chart Helm para publicar a aplicação e o NGINX em Kubernetes usando
a imagem versionada do projeto.

## Implementação e limites

O chart deve manter o Compose como caminho principal do desafio e oferecer
Kubernetes como extensão opcional. Deve incluir Deployment, Service, ConfigMap
do NGINX, probes, recursos mínimos e valores para imagem/tag.

## Aceite e verificação

- [ ] Chart Helm versionado.
- [ ] `helm lint` passa no CI.
- [ ] `helm template` gera manifests válidos.
- [ ] Documentação mostra instalação, upgrade e remoção.

## Segurança, observabilidade e recuperação

O app não deve expor porta diretamente fora do cluster. O NGINX permanece como
ponto de entrada HTTP. Recursos e probes devem favorecer rollback simples.

## Evidências

Pendentes para a implementação do ticket.
