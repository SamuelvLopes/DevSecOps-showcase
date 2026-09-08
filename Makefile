.DEFAULT_GOAL := help

.PHONY: help check
help:
	@printf '%s\n' 'Projeto Korp — bootstrap' '  make check  Verifica whitespace no diff Git (não executa testes de aplicação).'

check:
	git diff --check
	git diff --cached --check
