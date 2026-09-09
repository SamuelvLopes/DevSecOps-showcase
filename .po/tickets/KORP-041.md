# KORP-041 — Exemplos Terraform AWS/Azure para VM limpa

Status: done. Risco: médio. Depende de KORP-040.

## Objetivo

Adicionar exemplos reais de infraestrutura como código para provisionar uma VM
Ubuntu em AWS ou Azure e entregar os outputs necessários para executar o
playbook Ansible do projeto.

## Implementação e limites

Terraform fica responsável apenas pela infraestrutura: rede mínima, acesso HTTP,
SSH restrito por CIDR e VM Ubuntu. O deploy da aplicação continua no Ansible,
para preservar o requisito oficial de provisionamento por playbook.

As credenciais dos provedores, chaves privadas, arquivos `terraform.tfvars` e
estados locais não são versionados.

## Aceite e verificação

- [x] Exemplo AWS com contrato comum de variáveis e outputs.
- [x] Exemplo Azure com contrato comum de variáveis e outputs.
- [x] Outputs incluem `public_ip`, `ssh_user` e `ansible_inventory`.
- [x] Documentação descreve init, plan, apply, Ansible, validação HTTP e destroy.
- [x] CI valida formatação e sintaxe Terraform sem aplicar recursos.

## Segurança, observabilidade e recuperação

SSH deve ser restrito pelo operador usando `allowed_ssh_cidr`. HTTP é público
para permitir validação do NGINX na porta 80. O ambiente deve ser destruído após
a demonstração.

## Evidências

- `terraform fmt -check -recursive terraform`: passou localmente via `hashicorp/terraform:1.9.8` e no CI.
- `terraform validate`: passou para AWS e Azure localmente via `hashicorp/terraform:1.9.8` e no CI.
- GitHub Actions da PR #31: Terraform examples, Go quality, Docker and Compose, Compose smoke, Compose load observability, Compose recovery demo, govulncheck, Trivy e GitGuardian passaram.
- Execução real em cloud depende das credenciais do operador e não exige segredo versionado.
