# KORP-057 — Control node conteinerizado e storage driver do clean-room

Status: done. Risco: baixo. Depende de KORP-055.

## Objetivo

A primeira execução real do clean-room de KORP-055 encontrou dois bloqueios.
Nenhum é defeito do playbook — os dois são do harness de validação — mas ambos
impediam que a validação acontecesse.

## Bloqueio 1: Ansible exigido no host

`scripts/ansible-clean-room.sh` chamava `ansible`, `ansible-galaxy` e
`ansible-playbook` diretamente. Em máquina sem Ansible, o fluxo morre na
primeira delas:

```text
scripts/ansible-clean-room.sh: linha 70: ansible: comando não encontrado
make: *** [Makefile:63: ansible-clean-room-test] Erro 127
```

Além de bloquear, isso deixava a versão do Ansible variando entre
desenvolvedores e CI, o que contradiz o propósito de um clean-room reproduzível.

### Solução

`tests/clean-room/control-node.Dockerfile` define o control node com
`ansible-core` em versão fixada, cliente Docker e cliente SSH. O helper
`ansible_exec` no script passa a executar cada invocação do Ansible nesse
container.

Detalhes que a implementação exigiu:

- `--network host`, porque o inventário aponta para `127.0.0.1:2222`, que é a
  porta publicada pelo container alvo no host;
- socket do Docker montado, para que tasks que falam com a API do Docker se
  comportem como se partissem do host;
- `--user` com uid/gid do host, para não deixar arquivos de root em `.tmp/`;
- `/etc/passwd` e `/etc/group` montados em read-only. Sem eles o cliente SSH
  falha com `No user exists for uid 1000`, porque resolve o uid via `getpwuid`;
- `ANSIBLE_COLLECTIONS_PATH` em `.tmp/`, para não rebaixar a collection a cada
  execução.

`KORP_CLEAN_ROOM_LOCAL_ANSIBLE=1` mantém a possibilidade de usar o Ansible do
host.

## Bloqueio 2: BuildKit e overlayfs aninhado

Com o Ansible resolvido, o playbook avançou por instalação do Docker, criação da
rede, cópia da stack e pull das imagens, e falhou no `docker build` da aplicação
dentro do alvo:

```text
failed to solve: mount source: "overlay",
target: "/var/lib/docker/buildkit/containerd-overlayfs/cachemounts/...",
fstype: overlay
```

O BuildKit não consegue montar overlayfs aninhado dentro do DinD neste tipo de
host.

### Solução

`tests/clean-room/daemon.json` define `storage-driver: vfs` e o Dockerfile do
alvo o instala em `/etc/docker/daemon.json` antes de o Docker existir, para que
o daemon já suba com ele.

`vfs` funciona em qualquer aninhamento, ao custo de velocidade. É concessão do
harness, não da entrega: em VM real o driver padrão vale, e nada no
`compose.yaml` ou no playbook depende dessa escolha. A limitação já estava
declarada em KORP-055 — DinD não é prova equivalente a VM real — e esta é uma
manifestação concreta dela.

## Bloqueio 3: idempotência não verificada

`idempotence()` executava o playbook uma segunda vez sem olhar o resultado.
Isso prova que o playbook não quebra, não que seja idempotente: um recap com
`changed=5` passaria silenciosamente.

### Solução

A função passou a ler o `PLAY RECAP` e falhar se `changed` for diferente de
zero, ou se o número não puder ser lido.

## Aceite

- [x] `make ansible-clean-room-*` funciona em host sem Ansible instalado.
- [x] Versão do `ansible-core` fixada no control node.
- [x] Arquivos em `.tmp/` pertencem ao usuário do host, não a root.
- [x] `docker build` do playbook conclui dentro do alvo.
- [x] Segunda execução falha se o recap não trouxer `changed=0`.
- [x] Escape hatch para usar o Ansible do host documentado.
- [x] Limitações do DinD documentadas com o erro concreto que as motivou.

## Verificação

```bash
bash scripts/ansible-clean-room.sh down
bash scripts/ansible-clean-room.sh up
bash scripts/ansible-clean-room.sh ping
bash scripts/ansible-clean-room.sh provision
bash scripts/ansible-clean-room.sh validate
bash scripts/ansible-clean-room.sh idempotence
```

Resultado, com o control node conteinerizado e sem Ansible no host:

```text
ping     => clean-room | SUCCESS => {"changed": false, "ping": "pong"}
provision=> ok=28  changed=12  unreachable=0  failed=0  skipped=0
validate => {"nome":"Projeto Korp","horario":"2026-09-09T05:32:06Z"}
idempotence => ok=27  changed=0  unreachable=0  failed=0  skipped=1
              idempotence: second run reported changed=0
```

`bash -n scripts/ansible-clean-room.sh` sem erro de sintaxe. O parser do recap
foi exercitado com recaps sintéticos de `changed=0` e `changed=3`.

O ciclo completo em um único comando também foi executado, a partir de alvo
recém-criado, e terminou com código de saída 0:

```console
$ make ansible-clean-room-test
...
PLAY RECAP
clean-room : ok=28  changed=12  unreachable=0  failed=0  skipped=0
{"nome":"Projeto Korp","horario":"2026-09-09T05:35:56Z"}
PLAY RECAP
clean-room : ok=27  changed=0   unreachable=0  failed=0  skipped=1
idempotence: second run reported changed=0
{"nome":"Projeto Korp","horario":"2026-09-09T05:36:16Z"}
```

É exatamente o comando que antes falhava com `Erro 127`.

## Segurança e recuperação

O control node roda com o socket do Docker montado, o que equivale a acesso
root ao host — mesmo nível de privilégio que já era necessário para o script
manipular containers a partir do host, e restrito ao ambiente local de teste.
Nenhuma credencial é versionada: a chave SSH continua efêmera em `.tmp/`.

`/etc/passwd` e `/etc/group` entram em read-only e não expõem hashes de senha,
que vivem em `/etc/shadow` e não é montado.

Reversão é o revert do commit, que reintroduz a dependência de Ansible no host.
