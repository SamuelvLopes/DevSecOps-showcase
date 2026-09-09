# Control node do clean-room: Ansible, cliente Docker e SSH em imagem propria.
#
# Existe para que a validacao nao dependa do que esta instalado no host. Sem
# isso, `make ansible-clean-room-test` falha com "ansible: comando nao
# encontrado" em qualquer maquina que nao tenha Ansible, e a versao usada varia
# entre desenvolvedores e CI.
FROM python:3.13-alpine

ARG ANSIBLE_CORE_VERSION=2.21.4

RUN apk add --no-cache \
        bash \
        curl \
        docker-cli \
        git \
        openssh-client \
    && pip install --no-cache-dir "ansible-core==${ANSIBLE_CORE_VERSION}"

WORKDIR /repo
