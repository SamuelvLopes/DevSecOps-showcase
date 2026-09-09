FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    container=docker

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        openssh-server \
        python3 \
        sudo \
        systemd \
        systemd-sysv \
    && rm -rf /var/lib/apt/lists/*

# BuildKit nao consegue montar overlayfs aninhado dentro do DinB neste tipo de
# host: `docker build` falha com
#   failed to solve: mount source: "overlay" ... fstype: overlay
# vfs funciona em qualquer aninhamento, a custo de velocidade. E uma concessao
# do harness de clean-room, nao da entrega: em VM real o driver padrao vale.
COPY daemon.json /etc/docker/daemon.json

RUN useradd --create-home --shell /bin/bash ansible \
    && install -d -m 0700 -o ansible -g ansible /home/ansible/.ssh \
    && printf '%s\n' 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible \
    && chmod 0440 /etc/sudoers.d/ansible \
    && mkdir -p /run/sshd \
    && systemctl enable ssh.service

RUN systemctl mask \
    dev-hugepages.mount \
    sys-fs-fuse-connections.mount \
    systemd-remount-fs.service \
    getty.target \
    console-getty.service \
    || true

STOPSIGNAL SIGRTMIN+3

CMD ["/sbin/init"]
