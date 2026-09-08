.DEFAULT_GOAL := help

.PHONY: help check test
help:
	@printf '%s\n' 'Projeto Korp' '  make test   Executa testes Go com race detector.' '  make check  Executa formatação, vet, testes e whitespace.'

test:
	cd app && go test -race -cover ./...

check:
	test -z "$$(gofmt -l app)"
	cd app && go vet ./...
	$(MAKE) test
	git diff --check
	git diff --cached --check
