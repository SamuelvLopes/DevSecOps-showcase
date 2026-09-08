# Requisitos e evidências

Fonte: enunciado do desafio técnico Korp fornecido ao candidato. Esta é uma
síntese dos requisitos, separada das decisões adicionais da implementação.

Todos os itens abaixo estão pendentes no bootstrap. Caminhos citados como
destino são planejados e serão criados nos respectivos tickets.

| Requisito oficial | Destino planejado | Evidência de aceite |
| --- | --- | --- |
| Serviço Go chamado http-server-projeto-korp na 8080 | app/; KORP-002 | Teste HTTP e execução local |
| GET /projeto-korp: nome Projeto Korp e horario UTC por requisição | app/; KORP-002 | Contrato JSON, relógio controlado e UTC |
| Dockerfile para build e execução | app/Dockerfile; KORP-005 | Build e container respondendo |
| Instalar/configurar Docker no Linux | ansible/; KORP-011–013 | Provisionamento de VM limpa |
| Rede bridge; aplicação sem porta publicada | compose.yaml; KORP-006 | Inspeção de rede e PortBindings |
| NGINX oficial; host 80 → container 80; volume /etc/nginx/conf.d/ | nginx/; KORP-007 | nginx -t, mounts e curl pela porta 80 |
| Arquivo http-server-projeto-korp.conf com proxy para app:8080 | nginx/conf.d/; KORP-007 | Resposta pelo proxy e DNS interno |
| Disponibilidade e volume em padrão Prometheus | app/ e monitoring/; KORP-004/008 | Scrape UP e contador após requests |
| Prometheus e Grafana no Compose; dashboard funcional | monitoring/; KORP-008/009 | Query e dashboard com dados |
| Um comando Ansible provisiona as partes 1 e 2 | ansible/site.yml; KORP-011–013 | Primeiro run completo, failed=0 |
| Playbook valida HTTP e imprime resposta | ansible/; KORP-013 | JSON exibido e contrato validado |
| Repositório público e demonstração técnica | README e docs/; KORP-035–040 | Clone limpo, demo e explicação |

## Melhorias escolhidas

- Grafana provisionado automaticamente (bônus explícito do enunciado).
- Testes de contrato/concorrência, health, logs, timeouts e shutdown gracioso.
- Latência, taxa, erros e cardinalidade controlada; probes fora do volume principal.
- Runtime non-root, read-only e mínimo privilégio; interfaces administrativas em loopback.
- Ansible por roles, mudanças condicionais e segundo run sem alterações desnecessárias.
- CI integrada, scans bloqueantes, carga curta e demonstração de recuperação.

## Aceite final

Executar `curl http://localhost:80/projeto-korp` **na VM alvo** deve retornar HTTP
200 com exatamente `nome` e `horario`. O timestamp será RFC3339 em UTC calculado
por request. Chamadas no mesmo segundo podem legitimamente ter o mesmo texto.

Com controlador Ansible, collections e SSH/sudo documentados, um playbook deve
preparar a VM, buildar a imagem e subir toda a stack. A segunda execução deve
resultar em changed=0 sem reconstruir/recriar recursos desnecessariamente.
Grafana deve ter datasource e dashboard por UID validados; `up` mede o scrape,
enquanto o teste pelo NGINX verifica o caminho HTTP completo.

A demonstração deve incluir execução do playbook e dashboard com métricas reais.
