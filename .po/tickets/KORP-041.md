# KORP-041 — Exemplos Terraform AWS/Azure para VM limpa

Status: in_review. Risco: médio. Depende de KORP-040.

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

- `terraform fmt -check -recursive terraform`: pendente no CI quando Terraform
  estiver disponível.
- `terraform validate`: pendente no CI quando providers forem inicializados.
- Execução real em cloud depende das credenciais do operador e não exige segredo
  versionado.
