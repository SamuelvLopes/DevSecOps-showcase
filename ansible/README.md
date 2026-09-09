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

## Dependências

No **controlador**: Ansible e a collection `community.docker`, declarada em
`requirements.yml` e instalada pelo `ansible-galaxy` acima.

No **host alvo**: `python3-requests`, incluído em `korp_packages` e instalado
pela role `docker` antes de qualquer task que fale com o Docker.

Os módulos `community.docker.docker_network` e `docker_network_info` usam o
cliente de API próprio da collection, que importa `requests` e `urllib3` e
falha com `missing_required_lib` se eles não existirem no alvo. Em imagens
cloud do Ubuntu o pacote costuma vir presente por causa do cloud-init, mas
depender disso é sorte, não projeto — por isso ele é declarado explicitamente.
