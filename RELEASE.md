# Release v1.0.0

## Escopo

Entrega final do core do desafio Korp:

- aplicação Go `http-server-projeto-korp`;
- endpoint `GET /projeto-korp` na porta interna 8080;
- Dockerfile multi-stage com runtime mínimo;
- Docker Compose com rede bridge;
- NGINX oficial como entrada na porta 80;
- Prometheus e Grafana provisionados por arquivos;
- Ansible para instalação Docker, deploy da stack e validação;
- CI, security gates, smoke, carga curta, recuperação e demo.

## Validação

Validações locais executadas durante a entrega:

- `make check`;
- `make compose-config`;
- `make compose-smoke`;
- `make compose-load`;
- `make compose-recovery`;
- `make demo`;
- `make clean-checkout`.

Validações remotas executadas em pull requests:

- `Go quality`;
- `Docker and Compose`;
- `Compose smoke`;
- `Compose load observability`;
- `Compose recovery demo`;
- `Go vulnerability scan`;
- `Image vulnerability scan`;
- `GitGuardian Security Checks`.

## Execução rápida

```bash
make compose-up
curl http://localhost/projeto-korp
make compose-down
```

## Demo

```bash
make demo
```

## Provisionamento

```bash
cp ansible/inventories/local.ini.example ansible/inventories/local.ini
cd ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook site.yml
```

O inventário deve ser ajustado para a VM alvo antes da execução remota.
