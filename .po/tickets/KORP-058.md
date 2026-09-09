# KORP-058 — Evidência mostrada no README

Status: done. Risco: baixo. Depende de KORP-051, KORP-055 e KORP-057.

## Objetivo

O README tinha estrutura boa e evidência nenhuma. A seção "Evidências"
**descrevia** comandos e **listava** jobs de CI, sem mostrar uma única saída:

> Um comando imprime a evidência da entrega inteira: `make demo`. Percorre
> contrato HTTP, portas publicadas, target do Prometheus...

Um avaliador precisava confiar na descrição ou rodar o projeto para ver qualquer
coisa. E o repositório não tinha **nenhuma imagem versionada** — nada do
dashboard, que é justamente o artefato visual que o enunciado pede para
demonstrar.

KORP-051 já previa isso e deixou o item em aberto:

> Se houver screenshots reais versionadas, apresentar poucas evidências de alto
> valor, como Grafana sob carga, Ansible em VM limpa, CI verde.

Era o único critério de aceite daquele ticket que ficou desmarcado.

## Implementação

### Captura do dashboard

`docs/images/grafana-projeto-korp.png`, 1600x880, ~100 KB. Captura real do
Grafana provisionado, em modo kiosk, sob carga sustentada de ~1650 ciclos de
requisição, com janela de 5 minutos para que as séries fiquem contínuas.

A carga incluiu requisições a uma rota inexistente, então a série
`unknown GET 404` e a linha `4xx` aparecem com dado — a captura demonstra que o
rastreamento de erro funciona, não apenas o caminho felizes.

Colocada no Quick start, onde o dashboard é apresentado, e não numa seção de
anexos: é o ponto em que o avaliador decide se vale continuar lendo.

### Evidência textual

A seção "Evidências" passa a trazer a saída real de `make demo`, com o
`app 8080/tcp` visível — a prova de que a aplicação não publica porta no host.

Ganhou também a subseção do provisionamento em alvo limpo, com os dois
`PLAY RECAP` e o `changed=0` da segunda execução, mais a nota de que o script
verifica esse número em vez de apenas rodar de novo.

### Ajuste no dashboard

O painel `Latencia P95` exibia `950.0000 µs`: `decimals: 4` sobre unidade de
segundos auto-escalada para microssegundos gera quatro casas de ruído. Passou a
`decimals: 2`, exibindo `950.00 µs`.

Isso apareceu ao revisar a primeira captura — a captura pagou por si mesma antes
de ser versionada.

## Aceite

- [x] Saída real de `make demo` no README.
- [x] Screenshot do dashboard versionado, de execução real e sob carga.
- [x] Evidência do provisionamento em alvo limpo, com `changed=0`.
- [x] Limitação do DinD referenciada, sem vender clean-room como VM real.
- [x] Todos os links relativos e a imagem resolvem.
- [x] Job `Demo evidence` citado na tabela de CI.
- [x] `Latencia P95` legível.
- [x] `make compose-smoke` verde após o ajuste no dashboard.

## Verificação

```bash
python3 -c "import json; json.load(open('grafana/dashboards/projeto-korp.json'))"
make compose-smoke
make demo
```

A captura foi gerada com a stack no ar, carga sustentada e Chrome headless:

```bash
google-chrome --headless --window-size=1600,880 --virtual-time-budget=22000 \
  --screenshot=docs/images/grafana-projeto-korp.png \
  "http://127.0.0.1:3000/d/projeto-korp/projeto-korp?kiosk&from=now-5m&to=now"
```

Os números na captura são consistentes com o que o Prometheus respondia no
momento: 13.48 req/s, taxa de erro 0.00% e P95 em 950 µs.

## Segurança e recuperação

A captura mostra apenas `127.0.0.1`, nomes de rota do próprio serviço e
métricas agregadas. Não há token, cabeçalho, endereço de usuário ou qualquer
dado sensível — o acesso anônimo do Grafana é somente leitura e já documentado.

Reversão é o revert do commit. A imagem envelhece junto com a UI do Grafana; se
a versão do Grafana mudar de forma visível, vale recapturar em vez de deixar uma
captura antiga passando por atual.
