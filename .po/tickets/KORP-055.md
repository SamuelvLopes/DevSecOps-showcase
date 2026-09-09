# Ticket: KORP-055 — Clean-room Ansible com Ubuntu em Docker/DinD

Status: in_review. Risco: alto. Depende de KORP-013 e KORP-050.

## Objective

Criar um ambiente Ubuntu 24.04 descartável, executado em Docker, que funcione como alvo limpo do Ansible para validar automaticamente o provisionamento completo da stack sem depender de criar uma VM manual a cada teste.

O ambiente deve ser tratado explicitamente como **clean-room containerizado / Docker-in-Docker (DinD)**, e não como equivalente a uma VM real.

## Context

O desafio exige que o Ansible prepare um ambiente Linux com Docker, rede bridge, build da aplicação, Docker Compose, NGINX, Prometheus, Grafana e validação HTTP. A validação em host limpo é importante porque bugs de bootstrap só aparecem quando o alvo não possui dependências pré-instaladas.

Uma VM Ubuntu continua sendo a evidência humana mais fiel de um host real, mas um alvo Docker privilegiado permite repetir a validação rapidamente, destruir o ambiente e recriá-lo do zero de forma automatizada.

## Implementação atual

- `tests/clean-room/Dockerfile`: Ubuntu 24.04 com systemd, SSH, Python 3 e sudo, sem Docker pré-instalado.
- `tests/clean-room/README.md`: escopo, riscos, reprodução e distinção entre DinD e VM real.
- `ansible/inventories/clean-room.ini`: inventory dedicado ao alvo descartável.
- `scripts/ansible-clean-room.sh`: lifecycle do alvo, chave SSH efêmera, ping, provisionamento, validação, segunda execução e teardown.
- `Makefile`: targets `ansible-clean-room-*` para operação reproduzível.
- `.github/workflows/clean-room-image.yml`: build em PR e publicação da imagem no GHCR em `develop`/`main`.
- `.tmp/` ignorado pelo Git para impedir versionamento de chaves/estado efêmero.

Imagem GHCR planejada/publicada pelo workflow após merge:

`ghcr.io/samuelvlopes/devsecops-showcase/ansible-clean-room-ubuntu`

A implementação foi versionada, mas a execução DinD completa ainda precisa ser validada em um host Docker compatível antes de marcar o ticket como `done`.

## Scope

### In

- Criar uma imagem Ubuntu 24.04 específica para testes de clean-room.
- Incluir apenas o bootstrap mínimo necessário para o Ansible alcançar o host: `systemd`, SSH, Python 3 e `sudo`.
- Executar o alvo com os privilégios/cgroups necessários para permitir um Docker daemon interno.
- Não pré-instalar Docker Engine, Docker Compose, NGINX, Prometheus, Grafana ou a aplicação no alvo.
- Criar inventory Ansible específico para o alvo Docker.
- Automatizar criação, espera por SSH, execução do playbook, validação e teardown.
- Executar o playbook duas vezes no mesmo alvo para verificar idempotência.
- Validar ao final:
  - Docker instalado pelo Ansible;
  - rede Docker bridge criada;
  - containers esperados em execução;
  - endpoint `GET /projeto-korp` via NGINX;
  - aplicação sem exposição direta da porta 8080;
  - Prometheus disponível e target da aplicação `UP`;
  - Grafana saudável/provisionado.
- Registrar comandos de reprodução via Makefile ou script versionado.
- Documentar claramente as diferenças entre DinD e uma VM Ubuntu real.

### Out

- Substituir a validação final em VM como se DinD fosse prova equivalente de host real.
- Criar conta AWS, Azure, OCI ou qualquer recurso cloud.
- Compartilhar o socket Docker do host como atalho para fingir instalação de Docker dentro do alvo.
- Colocar Docker pré-instalado na imagem de clean-room.
- Usar o ambiente privilegiado fora do contexto de teste controlado.

## Risk

Alto, porque o alvo requer execução privilegiada, cgroups e Docker aninhado. Esse modelo é aceitável apenas como ambiente de teste local/CI controlado e não representa uma recomendação de arquitetura de produção.

## Invariants

- O alvo deve iniciar sem Docker Engine instalado.
- O mesmo `ansible/site.yml` usado no fluxo normal deve provisionar o alvo; não criar um playbook simplificado exclusivo para o teste.
- O endpoint externo da aplicação continua passando por NGINX na porta 80.
- A porta 8080 da aplicação não pode ser publicada no host do alvo.
- A segunda execução não pode mascarar mudanças com `changed_when: false` para operações que realmente alterem estado.
- O teste não deve afirmar que um container DinD é uma VM.

## Compatibility

Alvo de referência: Ubuntu 24.04 LTS em arquitetura amd64. Suporte a outras distribuições/arquiteturas não é requisito deste ticket.

## Dependencies

- KORP-013 — Validação e idempotência Ansible.
- KORP-050 — Nomenclatura literal do container e criação explícita da rede.

## Conflict hints

- `ansible/roles/stack/`
- `ansible/inventories/`
- `ansible/requirements.yml`
- `Makefile`
- `scripts/`
- `tests/`
- `.github/workflows/` caso a validação seja integrada ao CI.

## Acceptance criteria

- [x] Existe uma imagem Ubuntu 24.04 de clean-room versionada no repositório.
- [x] A imagem não contém Docker Engine ou Docker Compose pré-instalados.
- [ ] O alvo sobe de forma descartável com SSH, Python e sudo funcionais.
- [ ] `ansible -m ping` alcança o alvo.
- [ ] Uma única invocação de `ansible-playbook` provisiona Docker, rede, aplicação e observabilidade.
- [ ] O playbook conclui com `failed=0` e `unreachable=0`.
- [ ] O endpoint `/projeto-korp` responde corretamente via NGINX.
- [ ] `localhost:8080` não expõe a aplicação diretamente.
- [ ] Prometheus reporta a aplicação como disponível.
- [ ] Grafana responde saudável e mantém provisioning esperado.
- [ ] Uma segunda execução do playbook demonstra idempotência real e não apenas `changed_when: false` artificial.
- [x] O ambiente pode ser criado/removido por comandos versionados no Makefile/script.
- [x] README/docs deixam explícito que DinD é clean-room automatizado e que VM continua sendo validação mais fiel de host real.
- [ ] Workflow de build da imagem validado verde na PR.
- [ ] Imagem GHCR confirmada acessível após merge em `develop`/`main`.

## Verification

```bash
make ansible-clean-room-up
make ansible-clean-room-ping
make ansible-clean-room-provision
make ansible-clean-room-validate
make ansible-clean-room-idempotence
make ansible-clean-room-down
```

Fluxo completo:

```bash
make ansible-clean-room-test
```

A rotina de teste executa conceitualmente:

```text
build clean-room Ubuntu
→ start target
→ inject ephemeral SSH public key
→ wait SSH
→ ansible ping
→ ansible-galaxy collection install
→ ansible-playbook (primeira execução)
→ endpoint/network/runtime checks
→ ansible-playbook (segunda execução)
→ checks novamente
```

## Recovery

Como o alvo é descartável, a recuperação padrão é destruir o container/estado efêmero e recriar o ambiente do zero. Nenhum dado de produção deve existir nesse ambiente.

## Agent notes

- Preferir automação transparente a scripts mágicos difíceis de explicar.
- Não usar montagem de `/var/run/docker.sock` do host como substituto do Docker instalado dentro do alvo, pois isso invalidaria a principal hipótese testada.
- Se `systemd`/cgroups tornarem o ambiente excessivamente frágil em GitHub Actions, manter o teste como alvo local reproduzível e documentar a limitação em vez de enfraquecer o teste.
- A implementação deve preservar a trilha normal de Ansible e complementar, não substituir, a validação em VM.
