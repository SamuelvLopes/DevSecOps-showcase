# Release v1.2.3

## Escopo

Release patch documental para manter o README alinhado com a release publicada:

- versão atual no topo do README corrigida para `v1.2.3`;
- core Compose/Ansible, Terraform e Kubernetes permanecem inalterados.

## Validação

A PR documental passou na esteira completa: Go quality, Docker and Compose, Compose smoke, Compose load observability, Compose recovery demo, Demo evidence, Helm chart, Terraform examples, vulnerability scans e GitGuardian.

---

# Release v1.2.2

## Escopo

Release patch para o chart Kubernetes:

- NGINX do chart usa imagem unprivileged e porta alta no container;
- `securityContext` com `runAsUser: 101` mantém execução sem capabilities extras;
- documentação registra que o chart foi exercitado em cluster real;
- core Compose/Ansible permanece inalterado.

## Validação

Validações remotas executadas na PR do fix:

- `Go quality`;
- `Docker and Compose`;
- `Compose smoke`;
- `Compose load observability`;
- `Compose recovery demo`;
- `Demo evidence`;
- `Helm chart`;
- `Terraform examples`;
- `Go vulnerability scan`;
- `Image vulnerability scan`;
- `GitGuardian Security Checks`.

Validação operacional registrada em KORP-060:

- chart aplicado em microk8s;
- deployments da aplicação e do NGINX em `1/1 Running`;
- `GET /projeto-korp` respondendo pelo NGINX do cluster;
- `/metrics` expondo disponibilidade, contador e histograma.

---

# Release v1.2.1

## Escopo

Release patch de fechamento para envio da entrega:

- README com evidências reais exibidas diretamente: dashboard Grafana, saída de `make demo` e validação clean-room Ansible;
- screenshot versionado do dashboard Grafana sob carga;
- fechamento dos tickets KORP-054, KORP-056, KORP-057 e KORP-058;
- nenhum comportamento de runtime alterado em relação ao estado já validado em `develop`, exceto ajuste visual de casas decimais no painel `Latencia P95`.

## Validação

Validações remotas executadas na PR de evidências:

- `Go quality`;
- `Docker and Compose`;
- `Compose smoke`;
- `Compose load observability`;
- `Compose recovery demo`;
- `Demo evidence`;
- `Helm chart`;
- `Terraform examples`;
- `Go vulnerability scan`;
- `Image vulnerability scan`;
- `GitGuardian Security Checks`.

## Uso rápido

```bash
make compose-up
curl http://localhost:80/projeto-korp
make compose-down
```

---

# Release v1.2.0

## Escopo

Publicação de imagem, aderência literal ao enunciado e experiência de avaliação,
sobre a release v1.1.0:

- build e publicação da imagem no GHCR pelo workflow `Container Image`, com tag
  por branch, tag imutável `sha-<commit>` e `latest` em `main`;
- container da aplicação nomeado `http-server-projeto-korp`, como no enunciado,
  e nome de projeto Compose fixado em `projeto-korp`;
- criação explícita da rede bridge no playbook Ansible, idempotente e com
  validação de driver;
- README reestruturado para a experiência do avaliador, com diagrama Mermaid,
  matriz de requisitos e separação entre core oficial e showcase opcional;
- correção de intermitência em `make demo` e cobertura do comando em CI pelo
  job `Demo evidence`;
- atualizações de dependências: `nginx:1.31-alpine`, `prom/prometheus:v3.14.0`,
  `grafana/grafana-oss:13.0.2`, `actions/checkout@v7`, `actions/setup-go@v7` e
  `hashicorp/setup-terraform@v4`.

Esta release também traz `main` para o estado da entrega: a tag `v1.1.0` havia
sido publicada a partir de `develop` e `main` permaneceu atrás, o que deixava os
badges do README refletindo um estado anterior ao entregue.

Docker Compose e Ansible continuam sendo o caminho principal do desafio. GHCR,
Kubernetes e Terraform seguem como extensões: Helm e Terraform são validados
estaticamente em CI, sem cluster ou conta cloud em execução.

## Validação

Validações locais executadas durante a entrega:

- `make compose-smoke`;
- `make compose-load`;
- `make compose-recovery`;
- `make demo`, em três execuções consecutivas;
- `docker compose config` com nome de projeto resolvido como `projeto-korp`;
- converge do Compose sobre rede pré-criada com os labels de identidade;
- `sh -n scripts/demo-evidence.sh`;
- `docker pull` anônimo da imagem publicada no GHCR;
- verificação dos links relativos e dos badges do README.

Validações remotas executadas em pull requests:

- `Go quality`;
- `Docker and Compose`;
- `Compose smoke`;
- `Compose load observability`;
- `Compose recovery demo`;
- `Demo evidence`;
- `Helm chart`;
- `Terraform examples`;
- `Go vulnerability scan`;
- `Image vulnerability scan`;
- `GitGuardian Security Checks`.

## Uso rápido

```bash
make compose-up
curl http://localhost:80/projeto-korp
make compose-down
```

Imagem publicada:

```bash
docker pull ghcr.io/samuelvlopes/devsecops-showcase/http-server-projeto-korp:v1.2.0
```

Instalação em cluster:

```bash
helm upgrade --install projeto-korp charts/projeto-korp \
  --namespace projeto-korp \
  --create-namespace \
  --set image.tag=v1.2.0
```

## Pendências conhecidas

- `container-image.yml` ainda usa `actions/checkout@v4`, enquanto os demais
  workflows estão em `@v7`. Sem impacto funcional; fica para o Dependabot.
- O playbook Ansible não foi executado em VM limpa nesta release; a validação
  de KORP-050 cobriu as tasks por lint e pela simulação do caminho de rede.

---

# Release v1.1.0

## Escopo

Extensão Kubernetes e observabilidade sobre a release v1.0.1:

- chart Helm da aplicação e NGINX;
- `ServiceMonitor` para coleta de `/metrics`;
- valores Helm para kube-prometheus-stack, Loki, Tempo, Alloy e Beyla opcional;
- bootstrap OpenTelemetry opt-in na aplicação Go;
- workflow `Kubernetes` com `helm lint` e `helm template`;
- Dependabot direcionado para `develop`, preservando GitFlow.

Docker Compose e Ansible continuam sendo o caminho principal do desafio. A trilha
Kubernetes é uma extensão operacional validada por renderização Helm e preparada
para cluster real.

## Validação

Validações locais executadas durante a entrega:

- `go test -race -cover ./...`;
- `govulncheck ./...`;
- `make docker-build`;
- `make compose-config`;
- `make helm-lint`;
- `make helm-template`;
- `helm template` com OpenTelemetry habilitado;
- `terraform fmt -check -recursive terraform`;
- `git diff --check`.

Validações remotas executadas em pull requests:

- `Helm chart`;
- `Terraform examples`;
- `Go quality`;
- `Docker and Compose`;
- `Compose smoke`;
- `Compose load observability`;
- `Compose recovery demo`;
- `Go vulnerability scan`;
- `Image vulnerability scan`;
- `GitGuardian Security Checks`;
- validação de configuração Dependabot.

## Uso rápido

```bash
make helm-lint
make helm-template
```

Instalação em cluster:

```bash
helm upgrade --install projeto-korp charts/projeto-korp \
  --namespace projeto-korp \
  --create-namespace \
  --set image.tag=v1.1.0
```

Tracing é desabilitado por padrão e pode ser habilitado com:

```bash
helm upgrade --install projeto-korp charts/projeto-korp \
  --namespace projeto-korp \
  --set app.otel.enabled=true \
  --set app.otel.endpoint=http://observability-alloy.monitoring.svc.cluster.local:4318
```

---

# Release v1.0.1

## Escopo

Extensão incremental sobre a release v1.0.0:

- trilha Terraform cloud VM para AWS e Azure;
- VM Ubuntu com SSH restrito por CIDR e HTTP público;
- outputs comuns `public_ip`, `ssh_user` e `ansible_inventory`;
- integração operacional com o playbook Ansible existente;
- workflow `Terraform examples` para `terraform fmt` e `terraform validate`;
- documentação de uso, validação e destruição do ambiente cloud.

Terraform provisiona infraestrutura. Ansible continua responsável por instalar
Docker, copiar a stack, executar Compose e validar HTTP, Prometheus e Grafana.

## Validação

Validações locais executadas durante a entrega:

- `terraform fmt -check -recursive terraform` via `hashicorp/terraform:1.9.8`;
- `terraform validate` para AWS via `hashicorp/terraform:1.9.8`;
- `terraform validate` para Azure via `hashicorp/terraform:1.9.8`;
- checks Go via container `golang:1.27.1`;
- `make compose-config`.

Validações remotas executadas em pull requests:

- `Terraform examples`;
- `Go quality`;
- `Docker and Compose`;
- `Compose smoke`;
- `Compose load observability`;
- `Compose recovery demo`;
- `Go vulnerability scan`;
- `Image vulnerability scan`;
- `GitGuardian Security Checks`.

## Uso cloud

AWS:

```bash
cd terraform/examples/aws
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
terraform output -raw ansible_inventory > inventory.ini
ansible-playbook -i inventory.ini ../../../ansible/site.yml
curl http://$(terraform output -raw public_ip)/projeto-korp
terraform destroy
```

Azure:

```bash
cd terraform/examples/azure
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
terraform output -raw ansible_inventory > inventory.ini
ansible-playbook -i inventory.ini ../../../ansible/site.yml
curl http://$(terraform output -raw public_ip)/projeto-korp
terraform destroy
```

Arquivos `terraform.tfvars`, planos e estados locais não são versionados.

---

# Release v1.0.0

## Escopo

Entrega final do core do desafio Korp:

- aplicação Go `http-server-projeto-korp`;
- endpoint `GET /projeto-korp` na porta interna 8080;
- Dockerfile multi-stage com runtime mínimo;
- Docker Compose com rede bridge;
- NGINX oficial como entrada na porta 80;
- Prometheus e Grafana provisionados por arquivos;
- Ansible para instalação Docker, deploy da stack e validação;
- CI, security gates, smoke, carga curta, recuperação e demo.

## Validação

Validações locais executadas durante a entrega:

- `make check`;
- `make compose-config`;
- `make compose-smoke`;
- `make compose-load`;
- `make compose-recovery`;
- `make demo`;
- `make clean-checkout`.

Validações remotas executadas em pull requests:

- `Go quality`;
- `Docker and Compose`;
- `Compose smoke`;
- `Compose load observability`;
- `Compose recovery demo`;
- `Go vulnerability scan`;
- `Image vulnerability scan`;
- `GitGuardian Security Checks`.

## Execução rápida

```bash
make compose-up
curl http://localhost/projeto-korp
make compose-down
```

## Demo

```bash
make demo
```

## Provisionamento

```bash
cp ansible/inventories/local.ini.example ansible/inventories/local.ini
cd ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook site.yml
```

O inventário deve ser ajustado para a VM alvo antes da execução remota.
