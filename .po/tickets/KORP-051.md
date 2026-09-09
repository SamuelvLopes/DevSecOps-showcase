# KORP-051 — README orientado à experiência do avaliador

Status: in_review. Risco: baixo. Depende de KORP-049.

## Objective

Reestruturar o `README.md` para que um avaliador consiga entender, em poucos minutos, o que o desafio exigia, como a solução foi construída, quais evidências comprovam o funcionamento e quais extensões representam diferenciais além do core.

O README deve funcionar como porta de entrada auditável do projeto, sem duplicar toda a documentação de `docs/` e sem transformar a entrega em catálogo de tecnologias.

## Context

A comparação com os READMEs públicos dos concorrentes mostrou que o projeto já possui profundidade técnica suficiente, porém parte relevante dessa qualidade está escondida em documentos secundários.

Os melhores padrões observados foram:
- apresentação visual e arquitetura clara;
- matriz `requisito -> implementação -> evidência`;
- quick start curto;
- evidências operacionais visíveis;
- decisões técnicas resumidas;
- separação explícita entre core obrigatório e showcase opcional.

O README atual também precisa evitar status de release desatualizado e não deve dar destaque excessivo a cloud antes de apresentar o core oficial.

## Scope

### In

- Reescrever o topo do README com proposta de valor clara do projeto.
- Exibir status e release atual de forma coerente com o estado real do repositório.
- Adicionar arquitetura Mermaid diretamente no README.
- Adicionar uma matriz curta `requisito oficial -> implementação -> evidência/arquivo`.
- Manter o quick start principal curto e reproduzível.
- Destacar o fluxo Ansible de um comando como requisito central.
- Criar uma seção de evidências operacionais.
- Separar visualmente:
  - core oficial;
  - engenharia/qualidade;
  - showcase opcional.
- Resumir diferenciais de CI, DevSecOps, observabilidade, recovery e release engineering.
- Posicionar GHCR, Helm/Kubernetes, OpenTelemetry/Loki/Tempo e Terraform como extensões, sem confundi-las com requisitos obrigatórios.
- Manter links para documentação detalhada em `docs/`.
- Usar apenas badges reais e úteis, preferencialmente ligados a workflows existentes.
- Se houver screenshots reais versionadas, apresentar poucas evidências de alto valor, como Grafana sob carga, Ansible em VM limpa, CI verde e rollout Kubernetes.

### Out

- Não alterar comportamento da aplicação, Compose, Ansible ou Kubernetes apenas para atender ao README.
- Não criar screenshots, resultados ou evidências fictícias.
- Não afirmar execução real em AWS/Azure se apenas Terraform foi validado estaticamente.
- Não copiar texto ou estrutura de concorrentes.
- Não duplicar runbook, threat model, ADRs ou documentação extensa no README.
- Não transformar o README em documentação enciclopédica.

## Risk

Baixo. Alteração documental, porém existe risco reputacional se o README afirmar algo que o repositório não comprova.

## Invariants

- O core oficial deve continuar aparecendo como caminho principal da entrega.
- Cloud e Kubernetes devem permanecer opcionais em relação ao desafio oficial.
- Toda afirmação importante deve ser sustentada por código, configuração, CI, teste ou evidência real.
- O README não pode contradizer `compose.yaml`, workflows, documentação técnica ou releases publicadas.
- O requisito de horário UTC deve ser descrito corretamente.
- A porta `8080` da aplicação deve continuar descrita como não publicada no host no core Compose.

## Compatibility

A mudança deve preservar links públicos existentes quando possível e continuar legível no renderer Markdown do GitHub.

## Dependencies

- KORP-049 — publicação da imagem no GHCR, para que a seção de release/supply chain descreva um fluxo realmente disponível.

KORP-050 existe em outra branch para uma frente diferente e não é dependência funcional deste ticket.

## Proposed structure

```text
# Projeto Korp — DevOps / DevSecOps Showcase

badges reais
1 frase de contexto
status / latest release

## Architecture
Mermaid

## Requirements
matriz requisito -> implementação -> evidência

## Quick start
Compose / demo / Ansible

## Evidence
execução, observabilidade, CI, provisioning

## Engineering beyond the challenge
CI, security gates, k6, recovery, threat model, imagem imutável

## Optional showcase
GHCR, Helm/Kubernetes, OpenTelemetry/Loki/Tempo, Terraform

## Validation
comandos reproduzíveis

## Documentation
links para docs/
```

## Acceptance criteria

- [x] O topo do README permite identificar em menos de 60 segundos o objetivo, arquitetura e status da entrega.
- [x] Existe um diagrama Mermaid do caminho principal `cliente -> NGINX -> app -> Prometheus -> Grafana`.
- [x] Existe uma matriz resumida de requisitos oficiais com referência para implementação/evidência.
- [x] O README destaca explicitamente que o core oficial é Go + Docker + NGINX + Prometheus/Grafana + Ansible.
- [x] Kubernetes, GHCR, observabilidade LGTM/OTel e Terraform aparecem como diferenciais opcionais.
- [x] O README não implica que Terraform validado estaticamente equivale a infraestrutura cloud executada.
- [x] O status de release está consistente com as releases reais do GitHub.
- [x] O quick start principal continua curto e copiável.
- [x] O fluxo Ansible de um comando está visível e corretamente descrito.
- [x] Claims relevantes apontam para arquivo, teste, workflow, documentação ou comando de verificação.
- [x] Não há duplicações ou contradições relevantes entre seções.
- [x] Links internos são verificados.
- [x] O README continua legível sem exigir que o avaliador abra documentos secundários para entender o projeto.
- [ ] Screenshots, se adicionadas, correspondem a execuções reais e são poucas/evidentes.
      Não aplicável: nenhuma screenshot foi adicionada, para não versionar evidência que
      envelhece junto com a UI do Grafana.

## Verification

Revisão manual do README no GitHub e checagem dos links/claims contra:

```bash
make check
make compose-smoke
make demo
make ansible-syntax
make helm-lint
make helm-template
make terraform-validate
```

Também comparar o conteúdo final com:
- `docs/requirements.md`;
- `docs/architecture.md`;
- `docs/demo.md`;
- `docs/security-review.md`;
- `docs/kubernetes-observability.md`;
- releases e workflows atuais do GitHub.

## Verification results

Estrutura entregue, na ordem proposta: topo com badges reais e status,
Arquitetura (Mermaid), Requisitos do desafio (matriz), Quick start com o
provisionamento Ansible, Evidências, Engenharia além do desafio, Showcase
opcional, Validação, Endpoints e Documentação.

Os títulos ficaram em português, e não nos nomes ingleses do rascunho de
estrutura, para não misturar idiomas com o corpo do texto e com o restante de
`docs/`. A ordem e o conteúdo das seções seguem o proposto.

Afirmações checadas contra o repositório em execução:

- todos os links relativos resolvem;
- os dois badges retornam `200 image/svg+xml`, e os workflows `CI` e `Security`
  estão verdes no branch default;
- os nomes de job citados existem em `ci.yml` e `security.yml`;
- nós do diagrama Mermaid todos definidos e referenciados;
- `curl http://localhost:80/projeto-korp` retorna `nome` e `horario` RFC3339 UTC;
- `/health` responde 204 e `/metrics` expõe `projeto_korp_up` e
  `projeto_korp_http_requests_total`;
- Grafana responde sem credencial e serve o dashboard `projeto-korp` com dois
  painéis;
- container `http-server-projeto-korp` com `8080/tcp` e sem porta publicada;
- timeouts de servidor e log JSON conferidos em `app/internal/app/server.go`;
- nenhum `.tfstate` versionado, coerente com "Terraform nunca aplicado";
- `docker pull` anônimo da imagem GHCR na tag `develop` funciona, o que
  confirma o item que estava em aberto em KORP-049 sobre o package ser público.

Fora do escopo deste ticket: ao validar `make demo` para citá-lo na seção de
evidências, o comando falhou por uma race pré-existente de KORP-036. A correção
foi separada em KORP-052 para não misturar mudança de script e de CI com
alteração documental. Enquanto KORP-052 não estiver integrado, `make demo` é
intermitente.

## Recovery

A alteração pode ser revertida sem impacto no runtime. Em caso de README excessivamente longo ou contraditório, restaurar a versão anterior e reaplicar apenas as seções comprovadamente úteis.

## Agent notes

Priorizar clareza para o avaliador, não quantidade de conteúdo. A primeira tela do README deve vender a engenharia já existente; detalhes profundos continuam em `docs/`.

Antes de afirmar que uma extensão está operacional, verificar o estado real da branch/release correspondente. Não transformar configuração planejada ou validação estática em evidência de execução real.
