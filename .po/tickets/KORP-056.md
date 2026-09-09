# KORP-056 — Histograma de duração e dashboard RED

Status: done. Risco: médio. Depende de KORP-004 e KORP-009.

## Objetivo

O dashboard tinha os dois painéis exigidos pelo enunciado e nada além. Faltava o
sinal que permite ler o comportamento do serviço sob carga: duração.

Sem histograma não existe RED. A aplicação expunha apenas `projeto_korp_up` e
`projeto_korp_http_requests_total`, o que dá taxa e erros, mas não duração.

Isso também corrigia uma afirmação falsa: `docs/requirements.md` já listava
"Latência, taxa, erros e cardinalidade controlada" entre as melhorias, sem que
houvesse qualquer métrica de latência no código.

## Origem da ideia

Padrões observados em um projeto interno de observabilidade em Kubernetes:
segmentação por audiência, visão RED por serviço e dashboards versionados com
provisionamento automático.

O conteúdo daquele projeto não foi copiado, por duas razões:

1. nenhum dos dashboards funcionaria aqui — dependem de kube-state-metrics,
   Loki, Azure Monitor, PgBouncer, spanmetrics e dados de deploy, nada disso
   presente nesta stack, e os painéis viriam vazios;
2. é plataforma de terceiro em repositório privado, e este repositório é público.

O que foi aproveitado é o método: RED, e dashboard como código validado.

## Implementação

### Aplicação

- Novo histograma `projeto_korp_http_request_duration_seconds`, com buckets de
  1 ms a 10 s. Os limites inferiores são apertados porque o serviço responde em
  bem menos de um milissegundo; os superiores existem para manter timeouts e
  travamentos visíveis.
- `Collector.Record` passa a receber a duração; o middleware mede com
  `time.Since` em volta de `ServeHTTP`.
- Os buckets são armazenados por bucket, não acumulados, e `Render` acumula na
  saída. Observações acima do último bucket entram apenas em `count`, que é o
  que o bucket `+Inf` reporta.
- A soma é `float64` sobre `atomic.Uint64` com laço de compare-and-swap, para
  manter o coletor livre de lock no caminho de incremento, como já era o caso do
  contador.
- O histograma agrupa por rota e método, **sem** status, para manter limitado o
  número de séries de bucket.

### Dashboard

Oito painéis, todos consultando métricas realmente expostas:

| Painel | Consulta |
| --- | --- |
| Disponibilidade da aplicacao | `projeto_korp_up` |
| Taxa de requisicoes | `sum(rate(requests_total[5m]))` |
| Taxa de erro | razão de 5xx sobre o total |
| Latencia P95 | `histogram_quantile(0.95, ...)` |
| Volume de requisicoes | taxa por rota, método e status |
| Disponibilidade ao longo do tempo | auto-reporte e sucesso do scrape |
| Latencia P50 P95 P99 | quantis do histograma |
| Requisicoes por classe de status | 2xx, 4xx e 5xx separados |

Os dois painéis obrigatórios do enunciado permanecem com o nome explícito.

### Painéis vazios

Na primeira versão, "Taxa de erro" e a série de 5xx retornavam `SEM DADOS`: sem
nenhum 5xx registrado o seletor vira vetor vazio, e a divisão por vetor vazio
também é vazia. `clamp_min` protegia contra divisão por zero, não contra
numerador vazio. Corrigido com `or vector(0)` nas duas pontas, o que mantém o
painel em zero em vez de "No data".

### Teste

`scripts/smoke-compose.sh` deixa de comparar a lista exata de títulos e passa a:

- exigir a presença dos dois painéis obrigatórios pelo nome;
- exigir que **toda** query de **todo** painel referencie uma métrica exposta
  pela aplicação.

A segunda checagem é o que impede que um painel seja publicado apontando para
uma série inexistente — exatamente o risco que motivou não copiar os dashboards
de origem.

## Aceite

- [x] Histograma exposto em formato Prometheus válido, com buckets cumulativos,
      `_sum` e `_count`.
- [x] Observação acima do último bucket contabilizada em `+Inf` e `count`.
- [x] Histograma sem label de status.
- [x] `gofmt`, `go vet` e `go test -race -cover` limpos.
- [x] Cobertura do pacote `metrics` em 98.3%.
- [x] Todas as 11 queries do dashboard retornando dado real no Prometheus.
- [x] Nenhum painel com "No data".
- [x] Smoke, load, recovery e demo verdes.
- [x] Verificação visual registrada por screenshot real do Grafana no README.

## Verificação

```bash
docker run --rm -v "$PWD/app:/src" -w /src golang:1.27-alpine \
  sh -c 'gofmt -l . && go vet ./... && go test -race -cover ./...'
make compose-smoke
make compose-load
make compose-recovery
make demo
```

Cada query do dashboard foi executada contra a API do Prometheus com a stack no
ar; as 11 retornaram dado. Exemplo com 40 requisições geradas:

```
Latencia P50 P95 P99   p50 => 0.0005  p95 => 0.00095  p99 => 0.00099
Taxa de erro           erro 5xx => 0
Requisicoes por classe 2xx => 0.0667  4xx => 0  5xx => 0
```

## Segurança e recuperação

O histograma não registra caminho bruto, query string, IP nem user-agent: a
rota é normalizada por `routeLabel`, que reduz qualquer caminho desconhecido a
`unknown`. O conjunto de labels é fechado, então a cardinalidade não cresce com
tráfego hostil.

Reversão é o revert do commit. A métrica é aditiva: painéis e alertas que usam
apenas as duas métricas anteriores continuam funcionando.
