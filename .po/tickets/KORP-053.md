# KORP-053 — Release v1.2.0 e sincronização de main

Status: in_review. Risco: médio. Depende de KORP-049, KORP-050, KORP-051 e KORP-052.

## Objetivo

Publicar a release v1.2.0 e trazer `main` para o estado da entrega.

`main` estava 30 commits atrás de `develop` e, mais grave, atrás da própria tag
`v1.1.0`: a tag foi publicada a partir de `develop` e `main` nunca recebeu o
merge. Como `main` é o branch default, um avaliador que abre o repositório via
GitHub caía em uma versão anterior à entregue, e os badges do README refletiam
o estado desse branch.

## Escopo da release

- KORP-049 — build e publicação da imagem no GHCR;
- KORP-050 — container `http-server-projeto-korp` e criação explícita da rede
  no playbook;
- KORP-051 — README orientado à experiência do avaliador;
- KORP-052 — correção de intermitência em `make demo` e cobertura em CI;
- atualizações de dependências entregues pelo Dependabot: `nginx:1.31-alpine`,
  `prom/prometheus:v3.14.0`, `grafana/grafana-oss:13.0.2`,
  `actions/checkout@v7`, `actions/setup-go@v7` e `hashicorp/setup-terraform@v4`.

## Implementação

- `RELEASE.md` recebe a seção da v1.2.0 no topo, com escopo, validações locais
  e remotas, uso rápido e pendências conhecidas.
- `README.md` passa a declarar `v1.2.0` como release atual.
- `charts/projeto-korp/Chart.yaml` sobe `version` para `0.2.0` e `appVersion`
  para `1.2.0`. O `appVersion` estava em `1.0.1`, defasado desde a v1.1.0.
- Branch `release/v1.2.0` a partir de `develop`, PR para `main`, tag anotada
  `v1.2.0` e sincronização de `develop`.

## Versionamento

Minor bump. KORP-049 adiciona capacidade nova — publicação de imagem em
registry — e não apenas correção. KORP-050 e KORP-052 são correções e KORP-051 é
documentação, nenhuma delas quebra compatibilidade.

## Aceite

- [x] `RELEASE.md` com a seção da v1.2.0.
- [x] README declarando a release atual corretamente.
- [x] `appVersion` do chart coerente com a release.
- [ ] PR de `release/v1.2.0` para `main` com CI verde.
- [ ] Merge em `main`.
- [ ] Tag anotada `v1.2.0` publicada.
- [ ] GitHub release criada a partir da tag.
- [ ] `develop` sincronizado com `main` após a release.
- [ ] Imagem `v1.2.0` publicada no GHCR pelo workflow de tag.

## Verificação

Após o merge e a tag:

```bash
git log --oneline -1 origin/main
git describe --tags origin/main
docker pull ghcr.io/samuelvlopes/devsecops-showcase/http-server-projeto-korp:v1.2.0
```

Badges do README passam a refletir a CI do branch default com o conteúdo
entregue.

## Segurança e recuperação

A release não altera superfície de exposição: hardening do serviço, ausência de
porta publicada na aplicação e interfaces administrativas em loopback
permanecem como validados em KORP-050 e KORP-052.

O push em `main` dispara `Container Image`, que publica as tags `main` e
`latest`. A tag `v1.2.0` dispara a publicação da tag de release correspondente.

Recuperação: `main` é ancestral de `develop`, então o merge não descarta
histórico e pode ser revertido por revert do merge commit. A tag pode ser
removida e republicada se a metadata precisar de ajuste.
