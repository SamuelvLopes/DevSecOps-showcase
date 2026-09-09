# KORP-041 — Terraform cloud VM AWS/Azure

Status: done. Risco: médio. Depende de KORP-040.

## Objetivo

Adicionar uma trilha Terraform executável para provisionar uma VM Ubuntu em AWS
ou Azure e entregar os outputs necessários para executar o playbook Ansible do
projeto em ambiente limpo.

## Implementação e limites

Terraform fica responsável pela infraestrutura: rede mínima, acesso HTTP, SSH
restrito por CIDR e VM Ubuntu. O deploy da aplicação continua no Ansible, para
preservar o requisito oficial de provisionamento por playbook.

A implementação possui variantes AWS e Azure com o mesmo contrato operacional de
variáveis e outputs. As diferenças entre provedores ficam explícitas nos recursos
nativos de cada cloud.

Credenciais dos provedores, chaves privadas, arquivos `terraform.tfvars`, planos
e estados locais não são versionados.

## Aceite e verificação

- [x] Variante AWS executável com contrato comum de variáveis e outputs.
- [x] Variante Azure executável com contrato comum de variáveis e outputs.
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
- Execução de `terraform apply` depende das credenciais do operador e não exige segredo versionado.
