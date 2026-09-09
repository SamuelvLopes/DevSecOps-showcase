# KORP-043 — Release v1.0.1 Terraform cloud VM

Status: in_review. Risco: baixo. Depende de KORP-041.

## Objetivo

Promover para `main` a trilha Terraform cloud VM AWS/Azure adicionada em
`develop` após a release v1.0.0.

## Implementação e limites

A release v1.0.1 adiciona Terraform para provisionar VM Ubuntu em AWS ou Azure,
sem versionar credenciais, estados, planos ou valores locais. O deploy da
aplicação permanece no playbook Ansible.

KORP-042 permanece planejado como extensão posterior de Helm e observabilidade
Kubernetes LGTM.

## Aceite e verificação

- [x] Release notes v1.0.1 versionadas.
- [x] KORP-040 marcado como concluído.
- [x] KORP-041 incluído no escopo de release.
- [ ] PR de release aberta para `main`.
- [ ] GitHub Actions verdes na PR de release.
- [ ] Tag `v1.0.1` publicada.

## Segurança, observabilidade e recuperação

Sem segredos versionados. A execução cloud real depende das credenciais do
operador e deve terminar com `terraform destroy` para evitar custo recorrente.

## Evidências

- `terraform fmt` e `terraform validate` passaram para AWS/Azure em container e
  no CI dos PRs anteriores.
- Evidências finais serão registradas após PR de release e tag.
