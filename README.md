# Projeto Korp — DevOps / DevSecOps Showcase

[![CI](https://github.com/SamuelvLopes/DevSecOps-showcase/actions/workflows/ci.yml/badge.svg)](https://github.com/SamuelvLopes/DevSecOps-showcase/actions/workflows/ci.yml)
[![Security](https://github.com/SamuelvLopes/DevSecOps-showcase/actions/workflows/security.yml/badge.svg)](https://github.com/SamuelvLopes/DevSecOps-showcase/actions/workflows/security.yml)

Serviço HTTP em Go atrás de NGINX, com métricas Prometheus, dashboard Grafana
provisionado por arquivo e todo o ambiente provisionado por um único comando
Ansible.

O **core do desafio** é Go + Docker + NGINX + Prometheus/Grafana + Ansible.
Release atual: **v1.2.3**. Kubernetes e Terraform são extensões opcionais: o
chart foi exercitado em cluster real, e os exemplos de cloud têm `fmt` e
`validate` em CI.

## Arquitetura

```mermaid
flowchart LR
  cliente([cliente])
  subgraph rede["rede bridge · projeto-korp"]
    nginx["NGINX<br/>publica 80:80"]
    app["http-server-projeto-korp<br/>Go · :8080 sem porta no host"]
    prom["Prometheus<br/>127.0.0.1:9090"]
    graf["Grafana<br/>127.0.0.1:3000"]
  end
  cliente -->|"GET /projeto-korp"| nginx
  nginx -->|"proxy_pass app:8080"| app
  prom -.->|"scrape /metrics"| app
  graf -->|"datasource"| prom
```

A aplicação **não publica porta no host**: só é alcançável pela rede interna,
através do NGINX. Prometheus e Grafana ficam em loopback, fora da interface
pública. Detalhes e limites em [`docs/architecture.md`](docs/architecture.md).

## Requisitos do desafio

| Requisito oficial | Implementação | Evidência |
| --- | --- | --- |
| **Parte 1** — serviço Go na 8080, `GET /projeto-korp` com horário UTC por requisição, Dockerfile, rede bridge, app sem porta publicada, NGINX 80→80 com volume em `/etc/nginx/conf.d/` | [`app/`](app), [`app/Dockerfile`](app/Dockerfile), [`compose.yaml`](compose.yaml), [`nginx/http-server-projeto-korp.conf`](nginx/http-server-projeto-korp.conf) | `make compose-smoke` |
| **Parte 2** — disponibilidade e volume de requisições em padrão Prometheus, Prometheus e Grafana no Compose, dashboard do serviço | [`app/internal/metrics/`](app/internal/metrics), [`prometheus/prometheus.yml`](prometheus/prometheus.yml), [`grafana/`](grafana) | `make compose-load` |
| **Parte 3** — playbook que instala Docker, cria a rede, builda a imagem, sobe o Compose, configura NGINX e monitoramento, valida por HTTP e imprime a resposta | [`ansible/`](ansible) | `ansible-playbook site.yml` |
| **Bônus** — Grafana provisionado por arquivo em vez de configuração manual | [`grafana/provisioning/`](grafana/provisioning) | `make compose-smoke` valida datasource e dashboard por UID |

Matriz completa de requisito → arquivo → critério de aceite em
[`docs/requirements.md`](docs/requirements.md).

O dashboard vai além dos dois sinais obrigatórios e cobre RED — taxa, erros
e duração — em oito painéis. Os dois exigidos pelo enunciado continuam lá
com o nome explícito: "Disponibilidade da aplicacao" e "Volume de
requisicoes". `make compose-smoke` verifica que ambos existem e que **toda**
query do dashboard aponta para uma métrica realmente exposta pela aplicação,
para que nenhum painel possa ser publicado vazio.

## Quick start

Pré-requisitos: Docker, Docker Compose e GNU Make.

```bash
make compose-up
curl http://localhost:80/projeto-korp
```

```json
{"nome":"Projeto Korp","horario":"2026-09-09T03:40:51Z"}
```

O campo `horario` é resolvido a cada requisição, no instante da chamada, em UTC
e formato RFC3339. Duas chamadas no mesmo segundo podem legitimamente retornar
o mesmo texto.

Dashboard em <http://127.0.0.1:3000> — **acesso anônimo habilitado, sem login**.
O dashboard "Projeto Korp" já vem provisionado. Para gerar movimento nos
gráficos, `make compose-load`. Ao terminar, `make compose-down`.

![Dashboard Projeto Korp no Grafana, com disponibilidade, taxa de requisições, taxa de erro, latência P95, volume por rota, disponibilidade ao longo do tempo, quantis de latência e requisições por classe de status](docs/images/grafana-projeto-korp.png)

Captura real, sob carga, do dashboard provisionado por arquivo — não é mockup.
Os `404` na série `unknown GET 404` e na linha `4xx` vêm de requisições a uma
rota inexistente durante a coleta.

### Provisionamento completo por Ansible

As partes 1 e 2 sobem inteiras com um comando, em host Linux da família Debian
(alvo: Ubuntu 24.04 LTS):

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook site.yml
```

O playbook instala Docker, cria a rede bridge, copia a stack, executa o Compose
e ao final valida o endpoint HTTP, o target do Prometheus, o datasource e o
dashboard do Grafana — imprimindo a resposta de `/projeto-korp` no console.
Inventário e execução remota em [`ansible/README.md`](ansible/README.md).

## Evidências

Um comando imprime a evidência da entrega inteira. Saída real, não editada além
do corte de linhas de build:

```console
$ make demo

## HTTP contract
{"horario": "2026-09-09T12:30:40Z", "nome": "Projeto Korp"}

## Published ports
NAME                        IMAGE                            SERVICE      PORTS
http-server-projeto-korp    http-server-projeto-korp:local   app          8080/tcp
projeto-korp-grafana-1      grafana/grafana-oss:13.0.2       grafana      127.0.0.1:3000->3000/tcp
projeto-korp-nginx-1        nginx:1.31-alpine                nginx        0.0.0.0:80->80/tcp
projeto-korp-prometheus-1   prom/prometheus:v3.14.0          prometheus   127.0.0.1:9090->9090/tcp

## Prometheus target
up{job="http-server-projeto-korp"} = 1

## Request volume
sum(projeto_korp_http_requests_total) = 5489

## Grafana provisioning
datasource = prometheus
dashboard = projeto-korp

## Done
demo evidence passed
```

Repare em `app 8080/tcp`: sem porta publicada no host, como o enunciado exige.
`make demo` **derruba a stack ao final** — para navegar no Grafana, use
`make compose-up` e deixe a stack no ar.

### Provisionamento validado em alvo limpo

O playbook é executado contra um Ubuntu 24.04 descartável que sobe **sem Docker
Engine**, para que a instalação seja de verdade e não idempotência aparente:

```console
$ make ansible-clean-room-test

PLAY RECAP  (1ª execução)
clean-room : ok=28  changed=12  unreachable=0  failed=0  skipped=0

TASK [validate : Print project endpoint response]
{"horario": "2026-09-09T05:35:56Z", "nome": "Projeto Korp"}

PLAY RECAP  (2ª execução)
clean-room : ok=27  changed=0   unreachable=0  failed=0  skipped=1
idempotence: second run reported changed=0
```

A segunda execução com `changed=0` é verificada pelo script, que lê o
`PLAY RECAP` e falha se houver mudança — rodar duas vezes sem checar prova que o
playbook não quebra, não que seja idempotente. O `skipped=1` é a criação da rede
Docker sendo pulada por já existir.

Escopo e limites em [`tests/clean-room/README.md`](tests/clean-room/README.md):
é Docker-in-Docker, clean-room automatizado e reproduzível, **não** equivalente
a uma VM real.

### Verificações em CI

As mesmas verificações rodam em CI a cada pull request, em jobs separados:

| Job | O que comprova |
| --- | --- |
| `Compose smoke` | contrato HTTP pelo proxy, target do Prometheus, datasource e dashboard por UID, e que a aplicação não publica porta |
| `Compose load observability` | carga curta com [k6](scripts/load-k6.js) e o contador de requisições respondendo no Prometheus |
| `Compose recovery demo` | falha injetada no serviço e recuperação, com a métrica voltando a `1` |
| `Demo evidence` | o mesmo `make demo` acima, para que a evidência não apodreça |
| `Go quality` | testes com race detector, formatação e vet |
| `Go vulnerability scan` / `Image vulnerability scan` | `govulncheck` e scan da imagem, bloqueantes |

## Engenharia além do desafio

- **Imagem mínima e sem privilégio**: build multi-stage para `scratch`, usuário
  não-root, `read_only`, `cap_drop: ALL` e `no-new-privileges`
  ([`app/Dockerfile`](app/Dockerfile), [`compose.yaml`](compose.yaml)).
- **Operabilidade**: `/health`, encerramento gracioso em SIGINT/SIGTERM,
  timeouts de servidor e logs estruturados em JSON.
- **Segurança como gate**: `govulncheck` e scan de imagem bloqueiam a PR;
  threat model STRIDE e security review versionados.
- **Observabilidade RED**: além de disponibilidade e volume, a aplicação expõe
  um histograma de duração, o que permite P50/P95/P99 e taxa de erro por classe
  de status no dashboard. O histograma agrupa por rota e método, sem status,
  para manter limitado o número de séries de bucket.
- **Teste de carga e recuperação** automatizados, não só smoke.
- **Rastreabilidade**: uma branch e uma PR por ticket, com critérios de aceite
  registrados em [`.po/`](.po/README.md) e ADRs para as decisões estruturais.
- **Validação em checkout limpo** (`make clean-checkout`), garantindo que a
  entrega não depende de estado local.

## Showcase opcional

Fora do escopo do enunciado, presentes como demonstração de amplitude:

- **Imagem publicada no GHCR** pelo workflow `Container Image`, com tag por
  branch e tag imutável `sha-<commit>`. Disponível publicamente:
  ```bash
  docker pull ghcr.io/samuelvlopes/devsecops-showcase/http-server-projeto-korp:develop
  ```
- **Helm chart e Kubernetes** — chart da aplicação e do NGINX, `ServiceMonitor`
  para o kube-prometheus-stack, valores para Loki, Tempo, Alloy e Beyla, e
  bootstrap OpenTelemetry opt-in na aplicação.
  **Aplicado e exercitado em cluster real** (microk8s, Kubernetes v1.32.13):
  ambos os Deployments em `1/1 Running`, `/projeto-korp` respondendo o contrato
  através do NGINX e `/metrics` servindo as métricas, incluindo o histograma de
  duração. A coleta via `ServiceMonitor` requer o Prometheus Operator no
  cluster e é validada por `helm template`.
  Ver [`docs/kubernetes-observability.md`](docs/kubernetes-observability.md).
- **Terraform para AWS e Azure** — exemplos que provisionam uma VM Ubuntu para
  uso com o playbook, com `fmt` e `validate` em CI.
  Ver [`docs/terraform-cloud.md`](docs/terraform-cloud.md).

## Validação

Fluxo da entrega:

```bash
make compose-smoke      # HTTP, Prometheus, Grafana e portas publicadas
make compose-load       # carga curta com k6 e métrica no Prometheus
make compose-recovery   # falha injetada e recuperação do serviço
make clean-checkout     # valida a entrega em diretório temporário limpo
```

Qualidade e artefatos:

```bash
make check              # formatação, vet, testes com race detector e whitespace
make docker-build
make ansible-syntax
make helm-lint          # opcional
make terraform-validate # opcional
```

`make help` lista todos os targets. Para desenvolvimento direto da aplicação
(requer Go 1.27.1 ou superior):

```bash
cd app
go run ./cmd/http-server-projeto-korp
curl http://localhost:8080/projeto-korp
```

O endereço padrão é `:8080`; `HTTP_ADDRESS=:18080` permite outra porta em
desenvolvimento sem alterar o requisito do container.

## Endpoints

| Endpoint | Resposta |
| --- | --- |
| `GET /projeto-korp` | JSON com `nome` e `horario` UTC |
| `GET /health` | HTTP 204, sem corpo |
| `GET /metrics` | Exposição Prometheus: `projeto_korp_up` (gauge), `projeto_korp_http_requests_total` (counter) e `projeto_korp_http_request_duration_seconds` (histogram) |

## Documentação

Avaliação:

- [Requisitos e critérios de aceite](docs/requirements.md)
- [Arquitetura e limites](docs/architecture.md)
- [Roteiro de demo](docs/demo.md)
- [Technical walkthrough](docs/technical-walkthrough.md)

Operação e segurança:

- [Runbook](docs/runbook.md)
- [Threat model STRIDE](docs/threat-model.md)
- [Security review](docs/security-review.md)
- [Decisões técnicas (ADRs)](docs/decisions/ADR-001-compose-core.md)

Processo:

- [Releases](RELEASE.md)
- [GitFlow e convenções](docs/gitflow.md)
- [Governança GitHub](docs/github-governance.md)
- [Tickets e dependências](.po/README.md)
