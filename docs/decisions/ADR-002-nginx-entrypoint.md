# ADR-002 — NGINX como entrada HTTP da aplicação

Status: aceito para implementação. Data: 2026-09-08.

## Contexto e decisão

O serviço Go escuta internamente em 8080. Somente NGINX publica 80:80 para o
fluxo HTTP da aplicação. Usar imagem oficial, rede bridge compartilhada e mount
read-only em /etc/nginx/conf.d/ contendo http-server-projeto-korp.conf.

## Alternativa e consequências

Publicar 8080 simplificaria acesso direto, mas violaria o requisito e permitiria
contornar o proxy. Acesso administrativo a Prometheus/Grafana será limitado ao
loopback, com túnel SSH. HTTP sem TLS atende o cenário local exigido; exposição
pública exigiria uma decisão adicional sobre TLS e controle de acesso.

## Verificação e recuperação

Validar nginx -t, resposta pela porta 80 e ausência de PortBindings na aplicação.
Testar configuração antes de reload e preservar a última configuração válida.
Após recriação da aplicação, verificar resolução do upstream e recuperação.
