# Arquitetura planejada

Status: decisões iniciais; implementação e validação pendentes.

```text
Controlador Ansible -- SSH/sudo --> VM Ubuntu 24.04 LTS
                                      |
Cliente --> host:80 --> NGINX:80 --> http-server-projeto-korp:8080
                                      ^
                               Prometheus (scrape /metrics)
                                      ^
                               Grafana (datasource)
```

Os quatro serviços usarão uma rede Docker bridge explícita. A aplicação não
publicará porta no host. NGINX terá configuração versionada montada somente
para leitura em /etc/nginx/conf.d/ e resolverá a aplicação pelo DNS Docker.
O Ansible gerenciará a rede; o Compose a referenciará como externa. O quick
start manual deverá criar a mesma rede antes de iniciar o Compose.

Prometheus e Grafana terão acesso administrativo via loopback da VM, com túnel
SSH documentado para acesso pelo navegador do controlador. A senha Grafana será
gerada uma vez, persistida fora do Git e reutilizada pelo provisionamento.

## Fronteiras e operação

- O alvo inicial é uma VM dedicada Ubuntu 24.04 LTS; suporte só será declarado
  após validação. Docker neste desktop não substitui a prova em VM limpa.
- Ansible instala Docker/Compose, transfere fontes/configurações, cria rede,
  constrói a imagem e converge a stack. Alterações de código e configuração
  devem provocar apenas rebuild/reload/recriação necessários.
- Uma única rede é suficiente ao core. Separação adicional só entra se houver
  ameaça e teste de isolamento concretos.
- Não há banco, fila ou dependência externa na aplicação. Health comprova
  resposta do processo com HTTP 204; readiness separado exige semântica distinta.
- A aplicação define timeouts HTTP explícitos e trata SIGINT/SIGTERM para
  encerramento gracioso.
- Disponibilidade de scrape e disponibilidade pelo proxy são sinais distintos.
  O dashboard não deve apresentar scrape UP como prova de todo o caminho.
- Estado persistente: dados de Prometheus/Grafana e credencial local. Cleanup
  da demonstração não deve apagar volumes persistentes inadvertidamente.

## Decisões

- [Compose como core](decisions/ADR-001-compose-core.md)
- [NGINX e exposição](decisions/ADR-002-nginx-entrypoint.md)
- [Extensões futuras](decisions/ADR-003-showcase-kubernetes-cloud.md)

CI, scans e smoke tests serão introduzidos progressivamente. Não há ainda
evidência de disponibilidade, idempotência ou segurança de runtime.
