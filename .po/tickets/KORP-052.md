# KORP-052 — Flakiness em demo-evidence e cobertura de CI

Status: in_review. Risco: baixo. Depende de KORP-036.

## Objetivo

`make demo` é o comando de evidência única da entrega e falha de forma
intermitente:

```
## Request volume
request counter query returned no data
make: *** [Makefile:39: demo] Erro 1
```

Uma segunda execução passa. O comando é citado em `docs/demo.md` como roteiro
de demonstração e é o que um avaliador tende a rodar primeiro, então a
intermitência é especialmente custosa.

## Causa

`scripts/demo-evidence.sh` (KORP-036) usava `sleep 16` fixo antes de consultar o
target no Prometheus e, em seguida, consultava
`sum(projeto_korp_http_requests_total)` sem nenhum retry. O resultado passava a
depender do instante do scrape: o target podia estar `up` sem que a amostra do
contador já estivesse consultável.

`scripts/smoke-compose.sh` já resolvia o mesmo problema com espera por retry
(`wait_prometheus_target_up`), padrão que o script de evidência não seguia.

A falha passou despercebida porque `make demo` não era executado em CI. O
workflow cobria `compose-smoke`, `compose-load` e `compose-recovery`, mas não
`demo`.

## Implementação

- `scripts/demo-evidence.sh` ganha `prometheus_query`, `wait_target_up` e
  `wait_request_counter`, seguindo o padrão de espera de `smoke-compose.sh`.
  Ambas as esperas usam 24 tentativas com 5 segundos de intervalo.
- O `sleep 16` fixo foi removido, o que também reduz o tempo de execução no
  caso comum.
- As esperas gravam a resposta nos mesmos arquivos temporários que os blocos de
  impressão já leem, então a saída do comando não muda.
- `.github/workflows/ci.yml` ganha o job `demo-evidence`, dependente de
  `compose-smoke`, fechando a causa raiz da falha não detectada.

## Aceite

- [x] `sh -n scripts/demo-evidence.sh` sem erro de sintaxe.
- [x] `make demo` verde em três execuções consecutivas.
- [x] Saída do comando inalterada em relação à versão anterior.
- [x] Job `demo-evidence` presente em `ci.yml` e dependente de `compose-smoke`.
- [ ] Job `demo-evidence` verde na PR.

## Verificação

```bash
sh -n scripts/demo-evidence.sh
for n in 1 2 3; do make demo || break; done
```

Três execuções consecutivas locais retornaram
`sum(projeto_korp_http_requests_total) = 2` e `demo evidence passed`.

## Segurança e recuperação

Sem impacto em superfície de exposição: a mudança é de robustez de script de
evidência e de cobertura de CI, sem alteração na aplicação, no Compose ou no
Ansible. Reversão é o revert do commit.
