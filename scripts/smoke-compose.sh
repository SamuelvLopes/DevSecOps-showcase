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

wait_prometheus_target_up() {
  retries="$1"
  delay="$2"
  i=1
  while [ "$i" -le "$retries" ]; do
    curl -fsS "http://127.0.0.1:9090/api/v1/targets?state=active" > "$tmp_dir/targets.json"
    if python3 - "$tmp_dir/targets.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    payload = json.load(fh)

targets = payload["data"]["activeTargets"]
matches = [
    target for target in targets
    if target["labels"].get("job") == "http-server-projeto-korp"
    and target["health"] == "up"
]
raise SystemExit(0 if matches else 1)
PY
    then
      return 0
    fi
    sleep "$delay"
    i=$((i + 1))
  done
  return 1
}

trap cleanup EXIT INT TERM

docker compose down --remove-orphans >/dev/null 2>&1 || true
docker compose up --build -d

wait_url http://127.0.0.1/health 60 1
wait_url http://127.0.0.1:9090/-/ready 60 1
wait_url http://127.0.0.1:3000/api/health 60 1

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

wait_prometheus_target_up 12 5

curl -fsS "http://127.0.0.1:9090/api/v1/query?query=projeto_korp_up" > "$tmp_dir/up.json"
python3 - "$tmp_dir/up.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    payload = json.load(fh)

result = payload["data"]["result"]
if not result or result[0]["value"][1] != "1":
    raise SystemExit("projeto_korp_up did not return 1")
PY

curl -fsS "http://127.0.0.1:9090/api/v1/query?query=projeto_korp_http_requests_total" > "$tmp_dir/requests.json"
python3 - "$tmp_dir/requests.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    payload = json.load(fh)

result = payload["data"]["result"]
if not result:
    raise SystemExit("request counter metric is empty")
PY

curl -fsS http://127.0.0.1:3000/api/datasources/name/Prometheus > "$tmp_dir/datasource.json"
python3 - "$tmp_dir/datasource.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    payload = json.load(fh)

if payload["type"] != "prometheus":
    raise SystemExit("Grafana datasource type is not prometheus")
if payload["url"] != "http://prometheus:9090":
    raise SystemExit("Grafana datasource URL is unexpected")
if payload["uid"] != "prometheus":
    raise SystemExit("Grafana datasource UID is unexpected")
PY

curl -fsS http://127.0.0.1:3000/api/dashboards/uid/projeto-korp > "$tmp_dir/dashboard.json"
python3 - "$tmp_dir/dashboard.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    payload = json.load(fh)

dashboard = payload["dashboard"]
panels = dashboard["panels"]
panel_titles = {panel["title"] for panel in panels}
if dashboard["title"] != "Projeto Korp":
    raise SystemExit("Grafana dashboard title is unexpected")

# The two panels the challenge requires must always be there by name.
missing = {"Disponibilidade da aplicacao", "Volume de requisicoes"} - panel_titles
if missing:
    raise SystemExit(f"missing required Grafana panels: {sorted(missing)}")

# Every panel must query a metric the application actually exposes, so a panel
# can never ship pointing at a series that does not exist.
exposed = (
    "projeto_korp_up",
    "projeto_korp_http_requests_total",
    "projeto_korp_http_request_duration_seconds",
    'up{job="http-server-projeto-korp"}',
)
for panel in panels:
    for target in panel.get("targets", []):
        expr = target.get("expr", "")
        if not any(metric in expr for metric in exposed):
            raise SystemExit(f"panel {panel['title']!r} queries unknown metric: {expr!r}")
PY

app_id="$(docker compose ps -q app)"
nginx_id="$(docker compose ps -q nginx)"
docker inspect "$app_id" --format '{{json .NetworkSettings.Ports}}' | grep -F '"8080/tcp":null' >/dev/null
docker inspect "$nginx_id" --format '{{json .NetworkSettings.Ports}}' | grep -F '"HostPort":"80"' >/dev/null

echo "compose smoke passed"
