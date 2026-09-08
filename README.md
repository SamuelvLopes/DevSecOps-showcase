# Projeto Korp — DevSecOps Showcase

Implementação incremental do desafio técnico Korp: Go, Docker Compose, NGINX,
Prometheus, Grafana e provisionamento Ansible em Linux.

Status: serviço HTTP implementado com operabilidade básica; containerização e
infraestrutura em desenvolvimento.

## Entrega planejada

`cliente → NGINX :80 → http-server-projeto-korp :8080`

O serviço responderá a `GET /projeto-korp` com nome e horário UTC dinâmico.
Prometheus coletará métricas e Grafana terá dashboard provisionado por arquivos.
Ansible preparará uma VM Ubuntu 24.04 LTS e validará o ambiente com um comando.
Essas capacidades são planejadas, ainda não comprovadas nesta etapa.

## Navegação

- [Requisitos e critérios de aceite](docs/requirements.md)
- [Arquitetura e limites](docs/architecture.md)
- [Decisões técnicas](docs/decisions/ADR-001-compose-core.md)
- [Tickets e dependências](.po/README.md)
- [GitFlow e convenções](docs/gitflow.md)

## Execução local

```bash
cd app
go run ./cmd/http-server-projeto-korp
curl http://localhost:8080/projeto-korp
curl -i http://localhost:8080/health
curl http://localhost:8080/metrics
```

O endereço padrão é `:8080`; `HTTP_ADDRESS=:18080` permite usar outra porta em
desenvolvimento sem alterar o requisito do container.

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
make ansible-syntax
```

Requer Go 1.24 ou superior, Git e GNU Make. Testes de infraestrutura serão
adicionados junto aos componentes correspondentes.

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
Kubernetes e cloud são extensões futuras e não condicionam a entrega Compose/Ansible.
