# Requisitos e evidências

Fonte: enunciado do desafio técnico Korp fornecido ao candidato. Esta é uma
síntese dos requisitos, separada das decisões adicionais da implementação.

Os itens abaixo mapeiam o enunciado oficial para arquivos versionados e
verificações. Quando a evidência depender de VM limpa, isso fica indicado.

| Requisito oficial | Implementação | Evidência de aceite |
| --- | --- | --- |
| Serviço Go chamado http-server-projeto-korp na 8080 | `app/`; KORP-002 | Testes Go, execução local e Compose smoke |
| GET /projeto-korp: nome Projeto Korp e horario UTC por requisição | `app/`; KORP-002 | Testes de contrato, clock controlado e UTC |
| Dockerfile para build e execução | `app/Dockerfile`; KORP-005 | `make docker-build`, CI e smoke Compose |
| Instalar/configurar Docker no Linux | `ansible/`; KORP-011–013 | Playbook implementado; VM limpa em KORP-037 |
| Rede bridge; aplicação sem porta publicada | `compose.yaml`; KORP-006 | `docker compose config` e inspeção no smoke |
| NGINX oficial; host 80 → container 80; volume /etc/nginx/conf.d/ | `compose.yaml`, `nginx/`; KORP-007 | Curl pela porta 80 e mount read-only |
| Arquivo http-server-projeto-korp.conf com proxy para app:8080 | `nginx/http-server-projeto-korp.conf`; KORP-007 | Resposta pelo proxy e DNS interno |
| Disponibilidade e volume em padrão Prometheus | `app/internal/metrics`, `prometheus/`; KORP-004/008 | Scrape UP e contador após requisições |
| Prometheus e Grafana no Compose; dashboard funcional | `prometheus/`, `grafana/`; KORP-008/009 | APIs Prometheus/Grafana e dashboard por UID |
| Um comando Ansible provisiona as partes 1 e 2 | `ansible/site.yml`; KORP-011–013 | Playbook implementado; execução final em KORP-037 |
| Playbook valida HTTP e imprime resposta | `ansible/roles/validate`; KORP-013 | Validações versionadas; execução final em KORP-037 |
| Repositório público e demonstração técnica | `README.md`, `docs/`, `.po/`; KORP-035–040 | Runbook, demo e release final |

## Melhorias escolhidas

- Grafana provisionado automaticamente (bônus explícito do enunciado).
- Testes de contrato/concorrência, health, logs, timeouts e shutdown gracioso.
- Latência, taxa, erros e cardinalidade controlada; probes fora do volume principal.
- Runtime non-root, read-only e mínimo privilégio; interfaces administrativas em loopback.
- Ansible por roles, mudanças condicionais e segundo run sem alterações desnecessárias.
- CI integrada, scans bloqueantes, carga curta e demonstração de recuperação.

## Aceite final

Executar `curl http://localhost:80/projeto-korp` deve retornar HTTP
200 com exatamente `nome` e `horario`. O timestamp será RFC3339 em UTC calculado
por request. Chamadas no mesmo segundo podem legitimamente ter o mesmo texto.

Com controlador Ansible, collections e SSH/sudo documentados, um playbook deve
preparar a VM, buildar a imagem e subir toda a stack. A segunda execução deve
resultar em changed=0 sem reconstruir/recriar recursos desnecessariamente.
Grafana deve ter datasource e dashboard por UID validados; `up` mede o scrape,
enquanto o teste pelo NGINX verifica o caminho HTTP completo.

A demonstração deve incluir execução do playbook e dashboard com métricas reais.
