# KORP-060 — Chart do NGINX não subia em cluster real

Status: done. Risco: alto. Depende de KORP-042.

## Objetivo

O chart Helm era descrito como "validado por `helm lint` e `helm template` em
CI". Ao ser aplicado em cluster real pela primeira vez, o Deployment do NGINX
nunca ficou pronto:

```text
Error: INSTALLATION FAILED: resource Deployment/projeto-korp/projeto-korp-projeto-korp-nginx
not ready. status: InProgress, message: Available: 0/1
```

O pod entrava em `CrashLoopBackOff`, com 6 reinícios.

## Causa

```text
nginx: [emerg] chown("/var/cache/nginx/client_temp", 101) failed (1: Operation not permitted)
```

O `securityContext` do container tinha `capabilities.drop: [ALL]`, o que remove
`CAP_CHOWN`. O entrypoint da imagem oficial do `nginx` roda como root e faz
`chown` nos diretórios de cache; sem a capability, falha e o processo aborta.

`helm lint` e `helm template` não pegam isso: nenhum dos dois executa o
container. O defeito só aparece com um kubelet de verdade criando o pod.

Vale registrar o contraste: no Docker Compose o mesmo NGINX funciona, porque lá
o container não recebe `cap_drop` — o hardening do Compose está no serviço em
Go, não no proxy. A divergência entre os dois ambientes escondeu o problema.

## Implementação

Trocada a imagem por `nginxinc/nginx-unprivileged`, que já vem com as
permissões corretas nos diretórios de cache, roda como uid 101 e escuta em
porta alta:

- `values.yaml`: `nginxinc/nginx-unprivileged:1.31-alpine` e
  `nginx.containerPort: 8080`. A tag também acerta uma defasagem: o chart estava
  em `1.27-alpine` enquanto o Compose já usava `1.31-alpine`.
- `nginx-configmap.yaml`: `listen {{ .Values.nginx.containerPort }}`.
- `nginx-deployment.yaml`: `containerPort` pela variável, mais
  `runAsNonRoot: true` e `runAsUser: 101` no `securityContext`.

O `capabilities.drop: [ALL]` **permanece**. A correção não relaxa o hardening:
remove a necessidade de privilégio em vez de conceder privilégio. Escutar em
8080 também dispensa `CAP_NET_BIND_SERVICE`.

O Service não precisou mudar, porque já usava `targetPort: http` — porta
nomeada, resolvida pelo nome do container.

## Aceite

- [x] `helm lint` verde.
- [x] `helm template` renderiza 8080 no configmap, no container e como alvo do
      Service.
- [x] `capabilities.drop: [ALL]` mantido.
- [x] Container roda como non-root explícito.
- [x] Instalação em cluster real conclui com `STATUS: deployed`.
- [x] Pods de app e nginx em `1/1 Running`, nginx sem reinícios.
- [x] `/projeto-korp` responde o contrato através do NGINX no cluster.
- [x] `/metrics` expõe as métricas, incluindo o histograma de duração.
- [x] Recursos removidos após a validação.
- [ ] `ServiceMonitor` validado em cluster com Prometheus Operator.

## Verificação

Reproduzido primeiro em Docker, com o mesmo `securityContext` do chart, para não
usar o cluster como ambiente de tentativa:

```bash
docker run --rm --cap-drop ALL --user 101:101 nginxinc/nginx-unprivileged:1.31-alpine
# sobe sem erro; a imagem oficial falha no chown nas mesmas condicoes
```

Em cluster microk8s, servidor v1.32.13:

```text
=== HELM RELEASE ===
NAME          NAMESPACE     REVISION  STATUS    CHART               APP VERSION
projeto-korp  projeto-korp  2         deployed  projeto-korp-0.2.0  1.2.0

=== PODS ===
projeto-korp-projeto-korp-app-cdc4f59c9-v7vnp      1/1  Running  0  11m
projeto-korp-projeto-korp-nginx-5b45d5455b-bkfmv   1/1  Running  0  19s

=== SERVICES ===
projeto-korp-projeto-korp-app     ClusterIP  10.152.183.26   <none>  8080/TCP
projeto-korp-projeto-korp-nginx   ClusterIP  10.152.183.233  <none>  80/TCP

=== ENDPOINT VIA PORT-FORWARD (pelo NGINX) ===
GET /projeto-korp
{"nome":"Projeto Korp","horario":"2026-09-09T13:11:54Z"}
GET /health -> HTTP 204
GET /metrics:
projeto_korp_up 1
projeto_korp_http_requests_total{route="/projeto-korp",method="GET",status="200"} 1
projeto_korp_http_requests_total{route="/health",method="GET",status="204"} 148
projeto_korp_http_request_duration_seconds_count{route="/health",method="GET"} 148
```

As 148 requisições a `/health` são as probes de liveness e readiness — prova de
que as probes do chart estão de fato exercitando o serviço.

## Limites da validação

O cluster usado não tem o Prometheus Operator: o CRD
`servicemonitors.monitoring.coreos.com` não existe, e não há Grafana ou
Prometheus instalados. A instalação usou `--set serviceMonitor.enabled=false`.

Portanto o `ServiceMonitor` segue validado apenas por renderização. O README
passa a distinguir as duas coisas: chart aplicado e exercitado em cluster real;
coleta via `ServiceMonitor`, não.

## Segurança e recuperação

A validação rodou em namespace dedicado, criado para o teste, com Service
`ClusterIP` — sem exposição externa e sem conflito de porta com o que já existia
no cluster. Nenhum recurso fora desse namespace foi alterado, e nenhum secret
foi lido.

Ao final, `helm uninstall` e `kubectl delete ns` devolveram o cluster à contagem
original de namespaces, confirmada por consulta após a remoção.

Reversão é o revert do commit, que reintroduz o `CrashLoopBackOff`.
