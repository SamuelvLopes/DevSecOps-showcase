# KORP-001 — Bootstrap, governança e arquitetura

Status: in_review. Risco: baixo. Dependências: nenhuma.

## Objetivo e escopo

Tornar os requisitos, arquitetura, processo e limites da entrega compreensíveis
antes da implementação. Criar README, convenções, Makefile, DAG, ticket inicial,
requisitos, GitFlow, template de PR e três ADRs. Não adicionar aplicação/runtime
neste ticket.

## Aceite

- [x] Documentação distingue requisitos, melhorias e estado ainda planejado.
- [x] DAG preserva IDs e possui dependências válidas, sem ciclos.
- [x] Links relativos apontam a arquivos existentes.
- [x] make help, make check e revisão de secrets executados.
- [x] Branch e PR seguem GitFlow, com exceção inicial documentada.

## Segurança, observabilidade e recuperação

O .gitignore cobre
credenciais locais comuns, sem substituir revisão. Sem alteração de runtime;
recuperação por revert dos commits deste ticket. Métricas serão implementadas
nos tickets próprios.

## Evidências

- make help e make check: passaram em 2026-09-08.
- Leitura YAML: 25 IDs únicos, dependências existentes e sem ciclos no escopo ativo.
- Verificação de 11 links Markdown locais: todos apontam para arquivos existentes.
- Revisão manual dos arquivos e busca de padrões comuns de secrets: nenhum achado;
  isso não substitui o scanner previsto em KORP-015.
- Aplicação/CI não existem nesta etapa; nenhum teste funcional foi declarado.
- [PR #1](https://github.com/SamuelvLopes/DevSecOps-showcase/pull/1) aberta para develop.
- Ticket em revisão.
