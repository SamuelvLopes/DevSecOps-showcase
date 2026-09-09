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
