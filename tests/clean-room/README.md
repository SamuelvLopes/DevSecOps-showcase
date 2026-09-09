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
→ ansible-playbook (2ª execução)
→ validate novamente
```

## Imagem publicada

O workflow `clean-room-image.yml` faz build em pull requests e publica no GHCR em pushes para `develop`/`main`.

Imagem:

```text
ghcr.io/samuelvlopes/devsecops-showcase/ansible-clean-room-ubuntu
```

Tags esperadas incluem branch, `sha-<commit>` e, em `main`, `24.04` e `latest`.

A imagem publicada é uma conveniência para reprodução. A fonte de verdade continua sendo este Dockerfile versionado.
