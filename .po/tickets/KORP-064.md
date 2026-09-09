# KORP-064 — Release v1.2.4 ciclo DevOps e ISO/IEC

Status: in_review. Risco: baixo. Depende de KORP-063.

## Objetivo

Promover para `main` a seção do README sobre ciclo DevOps e referências ISO/IEC, junto com o ajuste de confiabilidade do Trivy DB.

## Escopo

- README mapeia `plan -> code -> build -> test -> release -> deploy/run -> observe -> improve`.
- README cita ISO/IEC 27001:2022, 27002:2022, 27005:2022 e 20000-1:2018 como referências, sem declarar certificação.
- Security workflow usa `TRIVY_DB_REPOSITORY=ghcr.io/aquasecurity/trivy-db`.

## Aceite

- [x] KORP-063 integrado em `develop`.
- [ ] PR de release aberta para `main`.
- [ ] GitHub Actions verdes na PR de release.
- [ ] Tag `v1.2.4` publicada.

## Evidências

- PR #65 passou em todos os checks e foi integrada em `develop`.
- A nova rodada comprovou o scan de imagem com Trivy DB via GHCR.
