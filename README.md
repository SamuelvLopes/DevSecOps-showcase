# Projeto Korp — DevSecOps Showcase

Implementação incremental do desafio técnico Korp: Go, Docker Compose, NGINX,
Prometheus, Grafana e provisionamento Ansible em Linux.

Status: core Compose implementado, observado e validado por CI. A validação em
VM limpa via Ansible é a próxima etapa antes da release final.

## Entrega

`cliente → NGINX :80 → http-server-projeto-korp :8080`

O serviço responde a `GET /projeto-korp` com nome e horário UTC dinâmico.
Prometheus coleta métricas da aplicação e Grafana carrega datasource/dashboard
por arquivos. Ansible prepara hosts Linux da família Debian, copia a stack,
executa Compose e valida HTTP, Prometheus e Grafana.

## Navegação

- [Requisitos e critérios de aceite](docs/requirements.md)
- [Arquitetura e limites](docs/architecture.md)
- [Threat model STRIDE](docs/threat-model.md)
- [Security review](docs/security-review.md)
- [Runbook](docs/runbook.md)
- [Demo](docs/demo.md)
- [Teste de carga e observabilidade](scripts/load-observability.sh)
- [Demo de recuperação](scripts/recovery-demo.sh)
- [Decisões técnicas](docs/decisions/ADR-001-compose-core.md)
- [Governança GitHub](docs/github-governance.md)
- [Tickets e dependências](.po/README.md)
- [GitFlow e convenções](docs/gitflow.md)

## Execução local

```bash
make compose-up
curl http://localhost/projeto-korp
curl -i http://localhost/health
curl http://localhost:9090/api/v1/query?query=projeto_korp_up
make compose-down
```

Para desenvolvimento direto da aplicação:

```bash
cd app
go run ./cmd/http-server-projeto-korp
curl http://localhost:8080/projeto-korp
```

O endereço padrão da aplicação é `:8080`; `HTTP_ADDRESS=:18080` permite usar
outra porta em desenvolvimento sem alterar o requisito do container.

Resposta:

```json
{"nome":"Projeto Korp","horario":"2026-09-08T20:15:30Z"}
```

O valor de `horario` corresponde ao instante da requisição em UTC.

`GET /health` retorna HTTP 204 e não possui corpo. O processo trata SIGINT e
SIGTERM com encerramento gracioso.

`GET /metrics` expõe métricas Prometheus para disponibilidade e volume de
requisições HTTP.

## Verificação

```bash
make test
make help
make check
make docker-build
make compose-up
make compose-down
make compose-smoke
make compose-load
make compose-recovery
make ansible-syntax
```

Requer Go 1.27.1 ou superior, Git, GNU Make, Docker e Docker Compose. Ansible é
necessário apenas para o provisionamento remoto.

O Compose cria a rede bridge `projeto-korp` e mantém a aplicação sem porta
publicada no host. O NGINX publica `80:80` e encaminha para `app:8080`.
Prometheus fica em `127.0.0.1:9090` para consulta local.
Grafana fica em `127.0.0.1:3000` com dashboard provisionado.

O diretório `ansible/` contém o playbook para instalar Docker, copiar a stack e
executar Compose em VM Linux. O playbook valida o endpoint HTTP, Prometheus e
Grafana ao final da execução.

## Processo

Uma branch e uma PR por ticket, commits rastreáveis e verificações registradas.
Cada ticket registra critérios de aceite e resultados de verificação.
Pull requests para `develop` e `main` executam CI com testes Go, build Docker e
validação Compose. Gates de segurança executam `govulncheck` e scan de imagem.
O smoke Compose valida HTTP, Prometheus e Grafana no fluxo completo. Carga curta
com k6 e demo de recuperação também rodam em CI.
Kubernetes e cloud são extensões futuras e não condicionam a entrega Compose/Ansible.
