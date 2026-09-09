#!/usr/bin/env sh
set -eu

source_dir="$(pwd)"
tmp_dir="$(mktemp -d)"

cleanup() {
  if [ -d "$tmp_dir/repo" ]; then
    (
      cd "$tmp_dir/repo"
      docker compose down --remove-orphans >/dev/null 2>&1 || true
    )
  fi
  rm -rf "$tmp_dir"
}

trap cleanup EXIT INT TERM

mkdir -p "$tmp_dir/repo"
tar \
  --exclude='./.git' \
  --exclude='./.pytest_cache' \
  --exclude='./coverage.out' \
  -cf - . | tar -C "$tmp_dir/repo" -xf -

cd "$tmp_dir/repo"
git init -q
git add .

echo "clean checkout path: $tmp_dir/repo"
make check
make compose-config
make demo

echo "clean checkout validation passed"
