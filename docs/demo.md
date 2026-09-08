# Demo

## Objetivo

Mostrar o caminho completo da entrega: aplicação Go, NGINX, Docker Compose,
Prometheus, Grafana, validações automatizadas, segurança e recuperação.

## Roteiro rápido

1. Apresente a matriz em `docs/requirements.md`.
2. Mostre a arquitetura em `docs/architecture.md`.
3. Rode a demo local:

   ```bash
   make demo
   ```

4. Mostre o dashboard Grafana em `http://127.0.0.1:3000`.
5. Mostre os workflows no GitHub Actions.
6. Feche com o runbook em `docs/runbook.md` e o threat model em
   `docs/threat-model.md`.

## Comandos de evidência

```bash
make check
make compose-smoke
make compose-load
make compose-recovery
make demo
make clean-checkout
```

`make demo` imprime contrato HTTP, portas publicadas, target Prometheus, volume
de requisições e provisionamento Grafana. O script usa diretório temporário e
remove a stack ao final.
`make clean-checkout` repete a verificação em diretório temporário.

## Pontos para explicar

- A aplicação só expõe `8080` dentro da rede Docker; a entrada pública é o NGINX
  na porta 80.
- O endpoint obrigatório retorna UTC calculado por requisição.
- Prometheus mede disponibilidade e volume por métricas próprias da aplicação.
- Grafana é provisionado por arquivos, sem configuração manual.
- CI executa qualidade, build, validação Compose, smoke, carga, recuperação e
  gates de segurança.
- Ansible automatiza instalação Docker, cópia da stack, execução Compose e
  validação final.
- A validação em VM limpa é o último passo antes da release final.
