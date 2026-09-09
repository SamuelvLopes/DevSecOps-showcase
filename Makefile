.DEFAULT_GOAL := help

.PHONY: ansible-clean-room-down ansible-clean-room-idempotence ansible-clean-room-ping ansible-clean-room-provision ansible-clean-room-test ansible-clean-room-up ansible-clean-room-validate ansible-syntax clean-checkout compose-load compose-recovery compose-smoke demo help check compose-config compose-down compose-up docker-build helm-lint helm-template terraform-fmt terraform-validate terraform-validate-aws terraform-validate-azure test
help:
	@printf '%s\n' 'Projeto Korp' '  make test            Executa testes Go com race detector.' '  make check           Executa formatação, vet, testes e whitespace.' '  make docker-build    Constrói a imagem da aplicação.' '  make compose-config  Valida compose.yaml.' '  make compose-up      Sobe a stack local.' '  make compose-down    Remove a stack local.' '  make compose-smoke   Executa smoke test da stack Compose.' '  make compose-load    Executa carga curta e valida métrica no Prometheus.' '  make compose-recovery Executa demo de falha e recuperação.' '  make demo            Executa roteiro curto de evidências.' '  make clean-checkout  Valida a entrega em diretório temporário limpo.' '  make ansible-syntax  Valida sintaxe do playbook quando Ansible estiver disponível.' '  make ansible-clean-room-up Sobe Ubuntu 24.04 descartável para Ansible.' '  make ansible-clean-room-ping Valida conectividade Ansible com o alvo.' '  make ansible-clean-room-provision Provisiona a stack no alvo limpo.' '  make ansible-clean-room-validate Valida HTTP/rede/runtime no alvo.' '  make ansible-clean-room-idempotence Executa o playbook novamente.' '  make ansible-clean-room-test Executa o fluxo clean-room completo.' '  make ansible-clean-room-down Remove o alvo clean-room.' '  make terraform-fmt   Valida formatação dos exemplos Terraform.' '  make terraform-validate Valida os exemplos Terraform AWS e Azure.' '  make helm-lint       Valida o chart Helm da aplicação.' '  make helm-template   Renderiza manifests Kubernetes.'

test:
	cd app && go test -race -cover ./...

check:
	test -z "$$(gofmt -l app)"
	cd app && go vet ./...
	$(MAKE) test
	git diff --check
	git diff --cached --check

docker-build:
	docker build -t http-server-projeto-korp:local app

compose-config:
	docker compose config --quiet

compose-up:
	docker compose up --build -d

compose-down:
	docker compose down --remove-orphans

compose-smoke:
	sh scripts/smoke-compose.sh

compose-load:
	sh scripts/load-observability.sh

compose-recovery:
	sh scripts/recovery-demo.sh

demo:
	sh scripts/demo-evidence.sh

clean-checkout:
	sh scripts/clean-checkout-validation.sh

ansible-syntax:
	cd ansible && ansible-playbook --syntax-check site.yml

ansible-clean-room-up:
	bash scripts/ansible-clean-room.sh up

ansible-clean-room-ping:
	bash scripts/ansible-clean-room.sh ping

ansible-clean-room-provision:
	bash scripts/ansible-clean-room.sh provision

ansible-clean-room-validate:
	bash scripts/ansible-clean-room.sh validate

ansible-clean-room-idempotence:
	bash scripts/ansible-clean-room.sh idempotence

ansible-clean-room-test:
	bash scripts/ansible-clean-room.sh test

ansible-clean-room-down:
	bash scripts/ansible-clean-room.sh down

terraform-fmt:
	terraform fmt -check -recursive terraform

terraform-validate-aws:
	cd terraform/examples/aws && terraform init -backend=false && terraform validate

terraform-validate-azure:
	cd terraform/examples/azure && terraform init -backend=false && terraform validate

terraform-validate: terraform-validate-aws terraform-validate-azure

helm-lint:
	docker run --rm -v "$$(pwd):/work" -w /work alpine/helm:3.16.4 lint charts/projeto-korp

helm-template:
	docker run --rm -v "$$(pwd):/work" -w /work alpine/helm:3.16.4 template projeto-korp charts/projeto-korp --namespace projeto-korp > /tmp/projeto-korp-rendered.yaml
