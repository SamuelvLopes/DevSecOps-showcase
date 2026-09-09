# Kubernetes observability

A trilha Kubernetes é opcional e complementa a entrega principal com Docker
Compose e Ansible. Ela organiza a aplicação em Helm e adiciona observabilidade no
modelo LGTM: Grafana, Loki, Tempo e métricas via Prometheus Operator.

## Componentes

- `charts/projeto-korp`: chart da aplicação e NGINX.
- `charts/observability/kube-prometheus-stack-values.yaml`: valores para
  Prometheus, Alertmanager e Grafana via kube-prometheus-stack.
- `charts/observability/loki-values.yaml`: valores mínimos para Loki em modo
  single binary.
- `charts/observability/tempo-values.yaml`: valores mínimos para Tempo.
- `charts/observability/alloy-values.yaml`: coleta de logs de pods e recebimento
  OTLP para traces.
- `charts/observability/beyla-values.yaml`: auto-instrumentação eBPF opcional,
  desabilitada por padrão operacional.

## Validação sem cluster

```bash
make helm-lint
make helm-template
```

Esses comandos validam o chart da aplicação e renderizam manifests com
`ServiceMonitor` habilitado. A instalação real requer um cluster Kubernetes e os
charts upstream adicionados localmente no operador.

## Instalação da aplicação

```bash
helm upgrade --install projeto-korp charts/projeto-korp \
  --namespace projeto-korp \
  --create-namespace \
  --set image.tag=v1.0.1
```

A aplicação continua atrás do NGINX. O Service do app é interno e o NGINX é o
ponto de entrada HTTP dentro do cluster.

Para testar localmente em cluster de desenvolvimento:

```bash
kubectl -n projeto-korp port-forward svc/projeto-korp-projeto-korp-nginx 8080:80
curl http://localhost:8080/projeto-korp
```

## Métricas com kube-prometheus-stack

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  -f charts/observability/kube-prometheus-stack-values.yaml
```

O chart da aplicação cria um `ServiceMonitor` para `/metrics`. A consulta base no
Prometheus é:

```promql
projeto_korp_up
```

Grafana e Prometheus não devem ser expostos publicamente por padrão. Use
`kubectl port-forward` ou túnel seguro para acesso administrativo.

## Logs com Loki e Alloy

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install loki grafana/loki \
  --namespace monitoring \
  -f charts/observability/loki-values.yaml
helm upgrade --install observability-alloy grafana/alloy \
  --namespace monitoring \
  -f charts/observability/alloy-values.yaml
```

Consulta LogQL sugerida:

```logql
{namespace="projeto-korp", container="app"}
```

A aplicação já emite logs JSON e não registra corpo de requisição, query string,
IP, user-agent ou headers sensíveis.

## Traces com Tempo e OpenTelemetry

```bash
helm upgrade --install tempo grafana/tempo \
  --namespace monitoring \
  -f charts/observability/tempo-values.yaml
helm upgrade --install projeto-korp charts/projeto-korp \
  --namespace projeto-korp \
  --set app.otel.enabled=true \
  --set app.otel.endpoint=http://observability-alloy.monitoring.svc.cluster.local:4318
```

Quando `OTEL_TRACES_ENABLED=true`, a aplicação inicializa OpenTelemetry e exporta
traces via OTLP HTTP. Sem essa variável, o comportamento permanece igual ao core.

## Beyla opcional

Beyla usa eBPF e pode exigir permissões sensíveis no nó. Por isso fica como bônus
controlado, depois que métricas, logs e traces explícitos estiverem funcionando.

```bash
helm upgrade --install beyla grafana/beyla \
  --namespace monitoring \
  -f charts/observability/beyla-values.yaml
```

## Remoção

```bash
helm uninstall projeto-korp -n projeto-korp
helm uninstall observability-alloy loki tempo monitoring -n monitoring
kubectl delete namespace projeto-korp monitoring
```
