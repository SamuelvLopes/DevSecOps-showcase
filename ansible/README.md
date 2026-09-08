# Ansible

O playbook `site.yml` provisiona a stack Projeto Korp em hosts Linux da família
Debian, com alvo principal Ubuntu 24.04 LTS.

## Inventário

Para uma VM remota, copie o exemplo e ajuste host, usuário e chave SSH:

```bash
cp ansible/inventories/local.ini.example ansible/inventories/local.ini
```

O arquivo versionado `inventories/local.ini` aponta para `localhost` apenas para
validação estrutural em desenvolvimento.

## Execução planejada

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook site.yml
```

KORP-012 implementa instalação do Docker e deploy da stack. KORP-013 implementa
validação HTTP, Prometheus e Grafana pelo playbook.
