# Technical walkthrough

## Abertura

Este repositório implementa o desafio Korp com uma aplicação Go simples,
containerização, NGINX como entrada HTTP, Prometheus/Grafana para observabilidade
e Ansible para provisionamento. O objetivo foi manter o requisito oficial claro
e adicionar qualidade operacional sem esconder o caminho principal.

## Fluxo principal

```text
cliente -> NGINX :80 -> app :8080 -> /projeto-korp
                         |
                         +-> /metrics <- Prometheus <- Grafana
```

A aplicação responde `GET /projeto-korp` com `nome` fixo e `horario` calculado
em UTC no momento da requisição. A porta `8080` fica restrita à rede Docker; o
host expõe apenas o NGINX em `80`.

## Escolhas técnicas

- Go foi usado pela simplicidade do binário, baixo custo de runtime e facilidade
  de testar contrato HTTP.
- A imagem final usa `scratch` e usuário não-root para reduzir superfície.
- Compose é o core porque atende diretamente o enunciado e permite demonstrar
  rede bridge, NGINX, Prometheus e Grafana com baixo atrito.
- Prometheus e Grafana ficam em loopback para demo local sem expor interfaces
  administrativas.
- Ansible organiza instalação Docker, cópia de arquivos, convergência da stack e
  validação final.
- CI executa qualidade, build, smoke, carga, recuperação e gates de segurança.

## Demonstração sugerida

```bash
make clean-checkout
make compose-smoke
make compose-load
make compose-recovery
```

Para apresentação curta, use:

```bash
make demo
```

O script mostra resposta HTTP, portas, target Prometheus, volume de requisições e
provisionamento Grafana.

## Perguntas prováveis

### Por que a aplicação não publica porta no host?

Porque o enunciado pede NGINX como proxy e a porta pública deve ser uma entrada
controlada. A aplicação fica acessível por DNS interno da rede Docker em
`app:8080`.

### O que prova que o horário é dinâmico?

Os testes de contrato usam relógio controlado e a implementação chama o relógio a
cada request antes de formatar em UTC. O smoke e a demo validam o formato no
fluxo real.

### O que prova observabilidade?

Prometheus coleta `/metrics` da aplicação e o dashboard Grafana é provisionado.
O teste de carga confirma que requisições em `/projeto-korp` aumentam o contador
`projeto_korp_http_requests_total`.

### Como a solução se recupera de falha?

O Compose define política de restart e o runbook mostra recuperação operacional.
A demo de recuperação injeta falha no serviço `app`, confirma indisponibilidade
momentânea e valida o retorno do endpoint e das métricas após recuperar o
serviço.

### Quais riscos foram aceitos?

O threat model documenta HTTP sem TLS para cenário local, Grafana anônimo apenas
em loopback, volumes persistentes para Prometheus/Grafana e ausência de
autenticação na aplicação porque o endpoint obrigatório é público e sem dados
sensíveis.

### O que ainda falta antes da release final?

Executar o playbook em uma VM limpa, registrar a saída da validação Ansible e
abrir a PR de release para `main` com tag final.
