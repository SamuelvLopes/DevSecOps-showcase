# Exemplos Terraform para AWS e Azure

Este projeto inclui exemplos Terraform executáveis para AWS e Azure. Os dois
seguem o mesmo contrato: criar uma VM Ubuntu com SSH restrito, HTTP público e
outputs prontos para alimentar o playbook Ansible.

Os exemplos são específicos por provedor de propósito. Terraform mantém os
recursos de cloud explícitos, enquanto Ansible continua responsável por instalar
Docker e subir a stack da aplicação.

## Fluxo comum

1. Escolha um provedor em `terraform/examples`.
2. Copie `terraform.tfvars.example` para `terraform.tfvars`.
3. Preencha `ssh_public_key` e `allowed_ssh_cidr`.
4. Autentique no provedor escolhido usando o fluxo oficial da AWS ou Azure.
5. Execute Terraform:

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

6. Gere o inventory a partir do output e execute Ansible:

```bash
terraform output -raw ansible_inventory > inventory.ini
ansible-playbook -i inventory.ini ../../../ansible/site.yml
```

7. Valide o endpoint público:

```bash
curl http://$(terraform output -raw public_ip)/projeto-korp
```

8. Destrua o ambiente após a demonstração:

```bash
terraform destroy
```

## AWS

O exemplo AWS cria VPC, subnet pública, internet gateway, route table, security
group, key pair e uma instância EC2 Ubuntu. O tipo padrão é `t3.micro` e a região
padrão é `us-east-1`.

Autenticação esperada no operador:

```bash
aws configure
# ou variáveis AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY e AWS_REGION
```

## Azure

O exemplo Azure cria resource group, virtual network, subnet, public IP, network
security group, network interface e uma Linux VM Ubuntu. O tamanho padrão é
`Standard_B1s` e a região padrão é `eastus`.

Autenticação esperada no operador:

```bash
az login
az account set --subscription <subscription-id>
```

## Outputs

Os dois exemplos retornam os mesmos outputs:

- `public_ip`: IP público da VM.
- `ssh_user`: usuário SSH padrão da imagem Ubuntu.
- `ansible_inventory`: inventory mínimo para executar o playbook.

Os arquivos em `docs/examples` mostram o formato esperado desses outputs. Após
uma execução real, substitua as amostras pelos valores retornados pelo Terraform
caso queira registrar evidência operacional.
