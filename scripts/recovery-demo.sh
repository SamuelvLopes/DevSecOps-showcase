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

wait_prometheus_up() {
  retries="$1"
  delay="$2"
  i=1
  while [ "$i" -le "$retries" ]; do
    curl -fsS "http://127.0.0.1:9090/api/v1/query?query=projeto_korp_up" > "$tmp_dir/up.json"
    if python3 - "$tmp_dir/up.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    payload = json.load(fh)

result = payload["data"]["result"]
raise SystemExit(0 if result and result[0]["value"][1] == "1" else 1)
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

before_id="$(docker compose ps -q app)"
docker compose kill app >/dev/null

if curl -fsS http://127.0.0.1/health >/dev/null 2>&1; then
  echo "health endpoint stayed available after app failure" >&2
  exit 1
fi

docker compose start app >/dev/null
wait_url http://127.0.0.1/health 60 1
after_id="$(docker compose ps -q app)"

sleep 16
wait_prometheus_up 10 2

curl -fsS http://127.0.0.1/projeto-korp > "$tmp_dir/project.json"
python3 - "$tmp_dir/project.json" <<'PY'
import json
import re
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    payload = json.load(fh)

if payload.get("nome") != "Projeto Korp":
    raise SystemExit(f"unexpected nome: {payload.get('nome')}")
if not re.fullmatch(r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z", payload.get("horario", "")):
    raise SystemExit(f"unexpected horario: {payload.get('horario')}")
PY

echo "recovered app service: $before_id -> $after_id"
echo "recovery demo passed"
