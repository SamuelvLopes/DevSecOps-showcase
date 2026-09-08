#!/usr/bin/env sh
set -eu

tmp_dir="$(mktemp -d)"

cleanup() {
  docker compose down --remove-orphans >/dev/null 2>&1 || true
  rm -rf "$tmp_dir"
}

wait_url() {
  url="$1"
  retries="$2"
  delay="$3"
  i=1
  while [ "$i" -le "$retries" ]; do
    if curl -fsS "$url" >/dev/null 2>&1; then
      return 0
    fi
    sleep "$delay"
    i=$((i + 1))
  done
  curl -fsS "$url" >/dev/null
}

section() {
  printf '\n## %s\n' "$1"
}

trap cleanup EXIT INT TERM

section "Build and start"
docker compose down --remove-orphans >/dev/null 2>&1 || true
docker compose up --build -d

wait_url http://127.0.0.1/health 60 1
wait_url http://127.0.0.1:9090/-/ready 60 1
wait_url http://127.0.0.1:3000/api/health 60 1

section "HTTP contract"
curl -fsS http://127.0.0.1/projeto-korp > "$tmp_dir/project.json"
python3 - "$tmp_dir/project.json" <<'PY'
import json
import re
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    payload = json.load(fh)

if sorted(payload.keys()) != ["horario", "nome"]:
    raise SystemExit(f"unexpected keys: {sorted(payload.keys())}")
if payload["nome"] != "Projeto Korp":
    raise SystemExit(f"unexpected nome: {payload['nome']}")
if not re.fullmatch(r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z", payload["horario"]):
    raise SystemExit(f"unexpected horario: {payload['horario']}")

print(json.dumps(payload, ensure_ascii=False, sort_keys=True))
PY

section "Published ports"
docker compose ps

section "Prometheus target"
sleep 16
curl -fsS "http://127.0.0.1:9090/api/v1/query?query=up%7Bjob%3D%22http-server-projeto-korp%22%7D" > "$tmp_dir/prometheus-up.json"
python3 - "$tmp_dir/prometheus-up.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    payload = json.load(fh)

result = payload["data"]["result"]
if not result:
    raise SystemExit("Prometheus target query returned no data")

value = result[0]["value"][1]
if value != "1":
    raise SystemExit(f"Prometheus target is not up: {value}")

print("up{job=\"http-server-projeto-korp\"} =", value)
PY

section "Request volume"
curl -fsS "http://127.0.0.1:9090/api/v1/query?query=sum(projeto_korp_http_requests_total)" > "$tmp_dir/prometheus-requests.json"
python3 - "$tmp_dir/prometheus-requests.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    payload = json.load(fh)

result = payload["data"]["result"]
if not result:
    raise SystemExit("request counter query returned no data")

print("sum(projeto_korp_http_requests_total) =", result[0]["value"][1])
PY

section "Grafana provisioning"
curl -fsS http://127.0.0.1:3000/api/datasources/name/Prometheus > "$tmp_dir/grafana-datasource.json"
curl -fsS http://127.0.0.1:3000/api/dashboards/uid/projeto-korp > "$tmp_dir/grafana-dashboard.json"
python3 - "$tmp_dir/grafana-datasource.json" "$tmp_dir/grafana-dashboard.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    datasource = json.load(fh)
with open(sys.argv[2], encoding="utf-8") as fh:
    dashboard = json.load(fh)["dashboard"]

if datasource["type"] != "prometheus":
    raise SystemExit("Grafana datasource type is not prometheus")
if datasource["uid"] != "prometheus":
    raise SystemExit("Grafana datasource UID is unexpected")
if dashboard["uid"] != "projeto-korp":
    raise SystemExit("Grafana dashboard UID is unexpected")

print("datasource =", datasource["uid"])
print("dashboard =", dashboard["uid"])
PY

section "Done"
echo "demo evidence passed"
