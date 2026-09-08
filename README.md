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

## Verificação

```bash
make test
make help
make check
```

Requer Go 1.24 ou superior, Git e GNU Make. Testes de infraestrutura serão
adicionados junto aos componentes correspondentes.

## Processo

Uma branch e uma PR por ticket, commits rastreáveis e verificações registradas.
Cada ticket registra critérios de aceite e resultados de verificação.
Kubernetes e cloud são extensões futuras e não condicionam a entrega Compose/Ansible.
