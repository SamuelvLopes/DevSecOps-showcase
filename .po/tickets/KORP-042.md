# KORP-042 — Helm chart da aplicação

Status: done. Risco: médio. Depende de KORP-041.

## Objetivo

Adicionar um chart Helm para publicar a aplicação e o NGINX em Kubernetes usando
a imagem versionada do projeto.

## Implementação e limites

O chart deve manter o Compose como caminho principal do desafio e oferecer
Kubernetes como extensão opcional. Deve incluir Deployment, Service, ConfigMap
do NGINX, probes, recursos mínimos e valores para imagem/tag.

## Aceite e verificação

- [x] Chart Helm versionado.
- [x] `helm lint` passa via `make helm-lint`.
- [x] `helm template` gera manifests em `/tmp/projeto-korp-rendered.yaml`.
- [x] Documentação mostra instalação, upgrade, port-forward e remoção.

## Segurança, observabilidade e recuperação

O app não deve expor porta diretamente fora do cluster. O NGINX permanece como
ponto de entrada HTTP. Recursos e probes devem favorecer rollback simples.

## Evidências

- `charts/projeto-korp` contém Deployment/Service da aplicação, ConfigMap/Deployment/Service do NGINX e ServiceMonitor.
- `.github/workflows/kubernetes.yml` valida lint e template.
