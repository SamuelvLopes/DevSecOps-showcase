# GitFlow do projeto

`ticket → branch → commits → PR → verificações → merge → release → evidência`

## Branches e commits

- main: estado estável; recebe releases e hotfixes por PR.
- develop: integração das features; deve permanecer verde.
- feature/KORP-XXX-descricao: nasce de develop; PR para develop.
- fix/, docs/ e ci/ seguem a mesma origem e destino.
- release/vX.Y.Z: nasce de develop; PR para main, tag anotada e sincronização de develop.
- hotfix/KORP-XXX-descricao: nasce de main; integrar correção em main e develop.

Commits: `<type>: <descrição curta em inglês> [KORP-XXX]`.
Exemplo: `feat: implement project endpoint in go [KORP-002]`.
Cada commit pertence a um ticket.

## Bootstrap excepcional

O remoto começou vazio. Um commit mínimo em main com README e .gitignore
estabeleceu a raiz Git. develop foi criada a partir dele; o restante do KORP-001
segue em feature/KORP-001-project-bootstrap. A exceção não se repete.

## Revisão e merge

Antes de editar: ler DAG, ticket, ADRs relacionados e código atual.
Antes de commit: git status, git diff, git diff --staged e revisão de secrets.
Antes da PR: git log --oneline develop..HEAD e verificações aplicáveis.
PRs incluem objetivo, alterações, aceite, evidência, riscos e recuperação.
Usar merge commit para preservar commits significativos e relação com o ticket.
O próximo ticket dependente começa após integração do anterior.

## Gates e releases

Bootstrap tem verificação documental local; CI ainda não existe. Quando os jobs
forem implementados, configurar proteção em main/develop com PR e checks
obrigatórios, bloqueio de force push/delete e conversas resolvidas.

Milestones: v0.1.0 runtime Go/Docker/NGINX; v0.2.0 observabilidade/Ansible;
v0.3.0 qualidade/segurança; v1.0.0 entrega validada e demonstrável.
Somente criar tags e releases quando o respectivo resultado existir.
