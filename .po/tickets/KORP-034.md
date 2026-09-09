# KORP-034 — Failure injection / recovery demo

Status: in_review. Risco: médio. Depende de KORP-013 e KORP-017.

## Objetivo

Demonstrar recuperação automática da aplicação após falha do container.

## Implementação e limites

`scripts/recovery-demo.sh` sobe a stack, valida saúde inicial, derruba o
container `app`, confirma a indisponibilidade momentânea via NGINX, recupera o
serviço com `docker compose start app`, valida `/health`, consulta Prometheus e testa novamente
`/projeto-korp`.

O teste cobre recuperação local do serviço de aplicação. Não simula falha de
host, perda de volume ou falha de rede externa.

## Aceite e verificação

- [x] Falha do container da aplicação injetada.
- [x] Indisponibilidade momentânea detectada via NGINX.
- [x] Serviço da aplicação recuperado.
- [x] `/health` volta a responder via NGINX.
- [x] Prometheus confirma `projeto_korp_up`.
- [x] Endpoint obrigatório volta a responder com contrato válido.
- [x] Job de CI executa o cenário.

## Segurança, observabilidade e recuperação

O teste usa a stack local e remove containers no fim. Recuperação por
`docker compose down --remove-orphans`.

## Evidências

- `make compose-recovery`: falha injetada no serviço `app`, `/health` recuperado,
  `projeto_korp_up` voltou a `1` e endpoint obrigatório respondeu com contrato
  válido.
- Saída do teste: `recovery demo passed`.
- Após o teste, `docker compose ps` não retornou containers ativos.
- GitHub Actions: pendente após abertura da PR.
