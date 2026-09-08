# Runbook

## Pré-requisitos

- Linux com Docker e Docker Compose para execução local.
- Go 1.27.1 ou superior para testes da aplicação.
- GNU Make, Git, curl e Python 3.
- Ansible para provisionamento remoto.

## Execução local completa

```bash
make compose-up
curl http://localhost/projeto-korp
curl -i http://localhost/health
make compose-down
```

Resposta esperada:

```json
{"nome":"Projeto Korp","horario":"2026-09-08T20:15:30Z"}
```

`horario` é calculado no momento da requisição em UTC.

## Verificação automatizada

```bash
make check
make compose-config
make compose-smoke
make compose-load
make compose-recovery
```

O smoke sobe a stack, valida o contrato HTTP via NGINX, confirma Prometheus,
confirma Grafana e inspeciona as portas publicadas. O teste de carga usa k6 e
confirma no Prometheus que o contador de requisições recebeu tráfego. A demo de
recuperação derruba o serviço `app`, confirma indisponibilidade momentânea,
recupera o serviço e valida saúde, métrica e contrato HTTP.

## Observabilidade

Prometheus fica disponível localmente em:

```text
http://127.0.0.1:9090
```

Consultas úteis:

```promql
projeto_korp_up
sum(projeto_korp_http_requests_total)
sum by (route, method, status) (projeto_korp_http_requests_total)
```

Grafana fica disponível localmente em:

```text
http://127.0.0.1:3000
```

O dashboard provisionado tem UID `projeto-korp`.

## Provisionamento com Ansible

Para uma VM remota, copie o inventário de exemplo e ajuste host, usuário e chave:

```bash
cp ansible/inventories/local.ini.example ansible/inventories/local.ini
```

Depois execute:

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook site.yml
```

O playbook instala Docker, copia a stack, executa Compose e valida HTTP,
Prometheus e Grafana. A execução em VM limpa deve ser registrada na validação
final.

## Recuperação operacional

Recriar a stack:

```bash
make compose-down
make compose-up
```

Recuperar apenas a aplicação parada:

```bash
docker compose start app
curl -i http://localhost/health
```

Executar demo completa:

```bash
make compose-recovery
```

## Limpeza

```bash
make compose-down
```

O comando remove containers e rede órfã, mas preserva volumes nomeados de
Prometheus e Grafana. Para apagar dados persistentes, use remoção explícita de
volumes somente quando isso for desejado.

## Troubleshooting

Se `curl http://localhost/projeto-korp` retornar 502, verifique a aplicação:

```bash
docker compose ps
docker compose logs app
docker compose start app
```

Se Prometheus não mostrar métricas, aguarde um intervalo de scrape e confira o
target:

```bash
curl http://127.0.0.1:9090/api/v1/targets?state=active
```

Se Grafana não carregar dashboard ou datasource, confira os arquivos
provisionados e reinicie o serviço:

```bash
docker compose restart grafana
```
