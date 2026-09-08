# Projeto Korp — DevSecOps Showcase

Implementação incremental do desafio técnico Korp: Go, Docker Compose, NGINX,
Prometheus, Grafana e provisionamento Ansible em Linux.

Status: bootstrap do repositório; aplicação e infraestrutura ainda não implementadas.

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

## Verificação desta etapa

```bash
make help
make check
```

Requer Git e GNU Make. O check atual verifica whitespace no diff; testes de
aplicação e infraestrutura serão adicionados junto aos componentes correspondentes.
O quick start operacional será publicado quando houver execução validada.

## Processo

Uma branch e uma PR por ticket, commits rastreáveis e verificações registradas.
Cada ticket registra critérios de aceite e resultados de verificação.
Kubernetes e cloud são extensões futuras e não condicionam a entrega Compose/Ansible.
