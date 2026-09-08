# Threat model STRIDE

## Escopo

Ambiente alvo: VM Ubuntu 24.04 LTS provisionada por Ansible. Componentes:
NGINX, aplicação Go, Prometheus, Grafana, Docker/Compose e GitHub Actions.

Fluxo principal: cliente HTTP acessa `host:80`, NGINX encaminha para `app:8080`
na rede Docker, Prometheus coleta `/metrics` e Grafana lê Prometheus.

## Ativos

- resposta de `GET /projeto-korp`;
- disponibilidade do serviço na porta 80;
- métricas e dashboard;
- playbook Ansible e configurações versionadas;
- credencial administrativa local do Grafana;
- histórico Git e regras de merge.

## Limites de confiança

- Internet para host HTTP na porta 80;
- rede Docker bridge entre serviços;
- interfaces administrativas em loopback do host;
- controlador Ansible com SSH/sudo para VM;
- GitHub Actions executando código do repositório.

## STRIDE

| Categoria | Ameaça | Controles implementados | Pendência |
| --- | --- | --- | --- |
| Spoofing | Acesso direto à aplicação ignorando NGINX | App sem `ports`; somente NGINX publica `80:80` | TLS/autenticação fora do escopo local |
| Spoofing | Acesso indevido a Prometheus/Grafana | Publicação em `127.0.0.1`; acesso por túnel SSH quando remoto | Senha Grafana gerada no provisionamento final |
| Tampering | Alteração de configuração em runtime | Mounts de NGINX, Prometheus e Grafana como read-only | Validar permissões na VM limpa |
| Tampering | Mudança insegura entrando por PR | CI, gates de segurança, GitGuardian e governança documentada | Branch protection aplicada no GitHub |
| Repudiation | Falta de rastreio de mudanças | GitFlow, PR por ticket e tickets com evidência | Release final com tag anotada |
| Information disclosure | Exposição de dados em logs/métricas | Logs não registram corpo; métricas sem IP, query string, user-agent ou payload | Revisão antes da entrega final |
| Denial of service | Cliente lento ou conexões ociosas | Timeouts HTTP e NGINX como entrada | Rate limit não implementado |
| Denial of service | Crescimento de cardinalidade em métricas | Labels de rota controladas; desconhecidas viram `unknown` | Validar sob carga curta |
| Elevation of privilege | Container com privilégios excessivos | App non-root, `scratch`, `read_only`, `cap_drop: ALL`, `no-new-privileges` | Avaliar hardening semelhante para serviços de terceiros |
| Elevation of privilege | Segredos ou permissões excessivas em CI | Workflows com `contents: read`; sem secrets | Proteções remotas documentadas |

## Riscos aceitos

- HTTP sem TLS atende o cenário local do desafio; exposição pública exigiria TLS
  e decisão operacional própria.
- Grafana tem acesso anônimo Viewer apenas em loopback para facilitar demo local.
- Prometheus e Grafana persistem dados em volumes; remoção completa deve ser
  deliberada.
- A aplicação não tem autenticação porque o endpoint obrigatório é público e não
  manipula dados sensíveis.

## Verificação

- `make check`
- `make compose-smoke`
- GitHub Actions: CI, security gates e GitGuardian
