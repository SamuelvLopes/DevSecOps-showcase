# Security review

## Escopo

Revisão do core entregue em Docker Compose: aplicação Go, imagem, NGINX,
Prometheus, Grafana, Ansible, workflows e governança de PR.

## Resultado

Nenhum bloqueio crítico foi identificado nesta revisão. Os controles existentes
cobrem o cenário local do desafio. A validação em VM limpa pode ser executada
com Ansible diretamente ou com os exemplos Terraform opcionais para AWS/Azure.

## Achados e controles

| Área | Controle verificado | Evidência |
| --- | --- | --- |
| Aplicação | Endpoint obrigatório sem autenticação e sem estado sensível | `GET /projeto-korp` retorna apenas nome e horário UTC |
| Aplicação | Timeouts e graceful shutdown | Servidor Go com limites de leitura, cabeçalho, escrita e idle |
| Métricas | Cardinalidade controlada | Labels de rota normalizados e métricas sem payload |
| Imagem | Runtime mínimo e usuário não-root | Dockerfile multi-stage com imagem final `scratch` e `USER 65532:65532` |
| Compose | Aplicação sem porta pública direta | Serviço `app` usa `expose: "8080"` e não usa `ports` |
| Compose | Redução de privilégios do app | `read_only`, `cap_drop: ALL` e `no-new-privileges:true` |
| NGINX | Entrada única HTTP | Serviço oficial NGINX publica `80:80` e encaminha para `app:8080` |
| Observabilidade | Interfaces administrativas locais | Prometheus e Grafana publicados em `127.0.0.1` |
| Configuração | Arquivos montados somente leitura | NGINX, Prometheus e provisioning/dashboards do Grafana usam volumes `:ro` |
| CI | Permissões reduzidas | Workflows usam `permissions: contents: read` |
| Segurança | Gates automatizados | `govulncheck`, Trivy e GitGuardian em PR |
| Governança | Mudança revisável por ticket | GitFlow, PR por ticket e template com checklist de segurança |

## Pendências operacionais para uso remoto

- Executar o playbook em VM limpa quando houver host alvo disponível.
- Gerar senha administrativa de Grafana fora do padrão local antes de uso remoto.
- Aplicar branch protection no GitHub conforme `docs/github-governance.md`.
- Registrar evidências de execução remota com Terraform output, Ansible output e resposta HTTP.

## Checklist para revisão futura

- Não publicar o serviço `app` diretamente no host.
- Manter Prometheus e Grafana restritos a loopback ou túnel SSH.
- Não adicionar segredos versionados.
- Não registrar payload, query string, IP, user-agent ou headers sensíveis em logs
  e métricas.
- Manter workflows com permissões mínimas.
- Reexecutar `make check`, `make compose-smoke` e security gates após mudanças de
  runtime.
