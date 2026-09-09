# KORP-063 — Ciclo DevOps e referências ISO/IEC no README

Status: in_review. Risco: baixo. Depende de KORP-062.

## Objetivo

Explicitar no README como a entrega percorre o ciclo DevOps e quais referências ISO/IEC orientam as práticas de segurança e operação, sem declarar certificação ou conformidade formal.

## Escopo

- Mapear `plan -> code -> build -> test -> release -> run -> observe -> improve` para evidências do repositório.
- Citar ISO/IEC 27001:2022, 27002:2022, 27005:2022 e 20000-1:2018 como referências conceituais.
- Manter a seção curta para não competir com o caminho principal do desafio.

## Aceite

- [x] README possui seção sobre ciclo DevOps.
- [x] README cita referências ISO/IEC sem alegar certificação.
- [x] Links e arquivos referenciados já existem no repo.
- [ ] PR integrada em `develop`.
- [ ] Release patch promovida para `main`.

## Verificação

```bash
git diff --check
rg -n "Ciclo DevOps|ISO/IEC" README.md
```

## Segurança e recuperação

Mudança documental. Reversão é o revert do commit.
