# KORP-054 — Dependência de requests no host alvo do playbook

Status: in_review. Risco: alto. Depende de KORP-050.

## Objetivo

KORP-050 passou a criar a rede Docker explicitamente no playbook, usando
`community.docker.docker_network` e `community.docker.docker_network_info`.
Esses módulos não usam o CLI do Docker: eles falam com a API por um cliente
próprio da collection, que importa `requests` e `urllib3`.

O playbook não instalava nenhum dos dois no host alvo. Em um host sem esses
pacotes, a task de rede falha com:

```
Failed to import the required Python library (requests)
```

E a falha acontece na role `stack`, ou seja, depois de instalar o Docker e antes
de subir a stack — deixando o provisionamento pela metade.

## Por que passou despercebido

O playbook nunca foi executado em VM limpa. As validações de KORP-050 cobriram
as tasks por lint de YAML e pela simulação do caminho de rede via Docker CLI,
que não exercita o cliente Python da collection.

Em imagens cloud do Ubuntu o `python3-requests` costuma estar presente porque o
cloud-init depende dele, o que tornaria a falha intermitente conforme a imagem
usada — o pior tipo de bug para uma demonstração ao vivo.

## Evidência da dependência

Inspeção do código da collection `community.docker` 5.3.0:

- `plugins/modules/docker_network.py` importa
  `module_utils/_common_api` e `module_utils/_api/errors`, e não o SDK do Docker;
- `plugins/module_utils/_api/_import_helper.py` importa `requests` e `urllib3`
  em bloco `try/except ImportError` e registra `REQUESTS_IMPORT_ERROR`;
- o mesmo arquivo chama
  `missing_required_lib("You have to install requests", "requests", ...)`
  quando o import falha.

A documentação dos módulos lista apenas "Docker API >= 1.25", sem mencionar os
pacotes Python — motivo pelo qual a dependência é fácil de perder.

## Implementação

- `python3-requests` adicionado a `korp_packages`, instalado pela primeira task
  da role `docker`. A ordem das roles (`docker` → `stack` → `validate`) garante
  que ele exista antes da task de rede.
- `ansible/README.md` ganha a seção "Dependências", separando o que é exigido no
  controlador e no host alvo, com a razão da dependência registrada para que ela
  não seja removida por parecer supérflua.

`urllib3` é dependência de `python3-requests` no apt, então não precisa ser
declarado separadamente.

## Aceite

- [x] `python3-requests` declarado em `korp_packages`.
- [x] Instalação ocorre antes de qualquer task que fale com a API do Docker.
- [x] Dependência documentada com a justificativa.
- [ ] Playbook executado em VM limpa, com segundo run sem alterações.

## Verificação

Só a execução em VM limpa fecha este ticket. Estruturalmente:

```bash
python3 -c "import yaml; yaml.safe_load(open('ansible/group_vars/korp.yml'))"
make ansible-syntax
```

## Segurança e recuperação

`python3-requests` vem dos repositórios oficiais da distribuição e não amplia
superfície de exposição. Reversão é o revert do commit, que reintroduz a falha.

Alternativa considerada e não adotada: trocar os módulos da collection por
`ansible.builtin.command` com `docker network create`, o que eliminaria tanto a
dependência de `requests` no alvo quanto a da collection no controlador,
tornando `ansible-playbook site.yml` suficiente sem o `ansible-galaxy` prévio.
Ficou de fora por ser mudança de estilo do playbook, que hoje é declarativo por
módulos, e deve ser decidida separadamente.
