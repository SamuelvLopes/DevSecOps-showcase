# KORP-066 — Comando do enunciado destacado no README

Status: in_review. Risco: baixo. Depende de KORP-065.

## Objetivo

Deixar explícito no README qual é o comando de validação completa da entrega e qual é o comando de teste funcional pedido no enunciado do desafio.

## Implementação

O Quick start ganhou a subseção "Comandos de validação", destacando o fluxo completo:

```bash
make ansible-clean-room-test
```

A mesma seção também mantém o comando HTTP exato do enunciado:

```bash
curl http://localhost:80/projeto-korp
```

O helper clean-room agora valida a presença do Docker e o acesso ao daemon antes de criar containers, retornando erro claro quando o host local ainda não está preparado.

A imagem do dashboard no README usa URL absoluta com `?raw=1`, para que a evidência renderize de forma estável no GitHub.

## Aceite

- [x] README destaca `make ansible-clean-room-test` como validação completa.
- [x] README destaca o `curl http://localhost:80/projeto-korp` pedido no enunciado.
- [x] Script informa quando Docker não está instalado ou não está acessível.
- [x] Evidência visual do dashboard renderiza por URL absoluta no README.
- [ ] PR integrada em `develop`.
- [ ] Promovido para `main`.

## Segurança e recuperação

Mudança documental. Reversão é o revert do commit.
