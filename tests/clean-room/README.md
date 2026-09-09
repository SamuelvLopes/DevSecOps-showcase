# Ansible clean-room Ubuntu 24.04

Este diretório define a imagem Ubuntu 24.04 usada como alvo descartável para validar o provisionamento Ansible do Projeto Korp.

## Objetivo

A imagem contém apenas o bootstrap necessário para o Ansible alcançar o alvo:

- Ubuntu 24.04;
- systemd;
- OpenSSH Server;
- Python 3;
- sudo;
- usuário `ansible` com sudo sem senha para o ambiente descartável de teste.

Ela **não** contém Docker Engine, Docker Compose, NGINX, Prometheus, Grafana ou a aplicação. Essas dependências devem ser instaladas/provisionadas pelo mesmo `ansible/site.yml` usado no fluxo normal.

## Segurança e escopo

O alvo roda com `--privileged` e acesso a cgroups para permitir Docker-in-Docker. Isso é deliberado e aceitável apenas no ambiente de teste local/CI controlado. Não é uma recomendação de produção e não deve ser descrito como VM real.

Nenhuma chave SSH privada é versionada. `scripts/ansible-clean-room.sh` gera uma chave efêmera em `.tmp/ansible-clean-room/` e injeta apenas a chave pública no container.

## Pré-requisitos

Apenas **Docker** e **GNU Make** no host, mais um cliente SSH (`ssh` e
`ssh-keygen`) para o handshake inicial com o alvo.

**Ansible não precisa estar instalado no host.** O `scripts/ansible-clean-room.sh`
executa `ansible`, `ansible-galaxy` e `ansible-playbook` dentro de um control
node conteinerizado, definido em `control-node.Dockerfile` com a versão do
`ansible-core` fixada. Antes disso, o fluxo falhava com
`ansible: comando não encontrado` em qualquer máquina sem Ansible, e a versão
usada variava entre desenvolvedores e CI.

O control node roda com `--network host` — o inventário aponta para
`127.0.0.1:2222`, que é a porta publicada pelo container alvo — e com o socket
do Docker montado, para que as tasks que falam com a API do Docker se comportem
como se partissem do host. Ele usa o uid/gid do host, para não deixar arquivos
de root em `.tmp/`; isso exige montar `/etc/passwd` e `/etc/group` em
read-only, porque o cliente SSH resolve o uid via `getpwuid`.

Para usar o Ansible do próprio host:

```bash
KORP_CLEAN_ROOM_LOCAL_ANSIBLE=1 make ansible-clean-room-test
```

## Storage driver do alvo

O alvo recebe `daemon.json` com `storage-driver: vfs`. O BuildKit não consegue
montar overlayfs aninhado dentro do DinD neste tipo de host, e o `docker build`
do playbook falha com:

```text
failed to solve: mount source: "overlay" ... fstype: overlay
```

`vfs` funciona em qualquer aninhamento, ao custo de velocidade. É uma concessão
do harness de clean-room, **não** da entrega: em VM real o driver padrão vale, e
nada no `compose.yaml` ou no playbook depende dessa escolha.

## Uso

Na raiz do repositório:

```bash
make ansible-clean-room-up
make ansible-clean-room-ping
make ansible-clean-room-provision
make ansible-clean-room-validate
make ansible-clean-room-idempotence
make ansible-clean-room-down
```

Ou o fluxo completo:

```bash
make ansible-clean-room-test
```

O teste completo:

```text
build Ubuntu clean-room
→ start container privilegiado
→ inject ephemeral SSH public key
→ wait SSH
→ ansible ping
→ install required Ansible collection
→ ansible-playbook (1ª execução)
→ validate HTTP/network/runtime
→ ansible-playbook (2ª execução), exigindo changed=0 no recap
→ validate novamente
```

A segunda execução não apenas roda de novo: o script lê o `PLAY RECAP` e falha
se `changed` for diferente de zero. Rodar duas vezes sem checar o recap prova
que o playbook não quebra, não que ele seja idempotente.

## Imagem publicada

O workflow `clean-room-image.yml` faz build em pull requests e publica no GHCR em pushes para `develop`/`main`.

Imagem:

```text
ghcr.io/samuelvlopes/devsecops-showcase/ansible-clean-room-ubuntu
```

Tags esperadas incluem branch, `sha-<commit>` e, em `main`, `24.04` e `latest`.

A imagem publicada é uma conveniência para reprodução. A fonte de verdade continua sendo este Dockerfile versionado.

## Resultado da validação

Execução completa em 2026-09-09, a partir de alvo recém-criado sem Docker e sem
`python3-requests`:

```text
PLAY RECAP (1ª execução)
clean-room : ok=28  changed=12  unreachable=0  failed=0  skipped=0

TASK [validate : Print project endpoint response]
{"horario": "2026-09-09T05:30:57Z", "nome": "Projeto Korp"}

PLAY RECAP (2ª execução)
clean-room : ok=27  changed=0   unreachable=0  failed=0  skipped=1
idempotence: second run reported changed=0
```

O `skipped=1` da segunda execução é a task de criação da rede Docker, pulada
pela guarda `docker_network_info` — o comportamento pretendido em KORP-050.

A validação também confirmou o alvo servindo pelo NGINX na porta 80 com a
aplicação sem porta publicada, e a ausência de exposição direta na 8080.
