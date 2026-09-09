# KORP-049 — Build e publicação da imagem no GHCR

Status: in_review. Risco: médio. Depende de KORP-042 e KORP-048.

## Objetivo

Garantir que a imagem da aplicação seja construída automaticamente no GitHub Actions e publicada no GitHub Container Registry para uso pelo chart Helm.

## Implementação

- Workflow `.github/workflows/container-image.yml`.
- Pull requests fazem build sem publicar.
- Push em `develop` e `main` publica a imagem no GHCR.
- Tags `v*` publicam a tag de release correspondente.
- Toda publicação recebe também tag imutável `sha-<commit>`.
- `main` publica também `latest`.
- Cache BuildKit via GitHub Actions.
- Permissões limitadas a `contents: read` e `packages: write`.
- Chart Helm usa a tag `main` por padrão para a demonstração contínua; deploys reproduzíveis podem sobrescrever `image.tag` com a tag SHA.

## Imagem

`ghcr.io/samuelvlopes/devsecops-showcase/http-server-projeto-korp`

## Aceite

- [x] PR executa build da imagem sem push.
- [x] Push em branches de integração/release publica no GHCR.
- [x] Imagem recebe tag baseada no SHA do commit.
- [x] Tags Git versionadas são refletidas no container registry.
- [x] Helm aponta para a mesma imagem publicada.
- [ ] Workflow validado verde após abertura da PR.
- [ ] Package GHCR confirmado como acessível pelo cluster; se necessário, tornar o package público após o primeiro push.

## Verificação

Após merge em `main`:

```bash
docker pull ghcr.io/samuelvlopes/devsecops-showcase/http-server-projeto-korp:main
```

Para deploy imutável:

```bash
helm upgrade --install projeto-korp charts/projeto-korp \
  --namespace projeto-korp \
  --create-namespace \
  --set image.tag=sha-<commit-sha>
```

## Segurança e recuperação

O workflow usa apenas `GITHUB_TOKEN`, sem PAT ou credencial estática. Em caso de falha, o workflow pode ser revertido sem afetar o core Compose/Ansible.
