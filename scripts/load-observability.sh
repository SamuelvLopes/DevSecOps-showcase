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

trap cleanup EXIT INT TERM

docker compose down --remove-orphans >/dev/null 2>&1 || true
docker compose up --build -d

wait_url http://127.0.0.1/health 60 1
wait_url http://127.0.0.1:9090/-/ready 60 1

docker run --rm \
  --network host \
  -v "$PWD/scripts/load-k6.js:/scripts/load-k6.js:ro" \
  grafana/k6:0.55.0 run /scripts/load-k6.js

sleep 20

curl -fsS "http://127.0.0.1:9090/api/v1/query?query=sum(projeto_korp_http_requests_total%7Broute%3D%22%2Fprojeto-korp%22%2Cstatus%3D%22200%22%7D)" > "$tmp_dir/requests.json"
python3 - "$tmp_dir/requests.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    payload = json.load(fh)

result = payload["data"]["result"]
if not result:
    raise SystemExit("request counter query returned no data")

value = float(result[0]["value"][1])
if value < 20:
    raise SystemExit(f"expected at least 20 observed project requests, got {value}")

print(f"observed projeto-korp requests: {value:.0f}")
PY

echo "load observability passed"
