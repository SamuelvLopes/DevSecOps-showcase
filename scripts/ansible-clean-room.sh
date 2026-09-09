#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="${ROOT_DIR}/.tmp/ansible-clean-room"
KEY_FILE="${STATE_DIR}/id_ed25519"
CONTAINER_NAME="korp-ansible-clean-room"
IMAGE_NAME="korp-ansible-clean-room:local"
SSH_PORT="${KORP_CLEAN_ROOM_SSH_PORT:-2222}"
HTTP_PORT="${KORP_CLEAN_ROOM_HTTP_PORT:-8088}"

ensure_key() {
  mkdir -p "${STATE_DIR}"
  if [[ ! -f "${KEY_FILE}" ]]; then
    ssh-keygen -q -t ed25519 -N "" -f "${KEY_FILE}" -C "korp-clean-room"
  fi
}

wait_for_ssh() {
  for _ in $(seq 1 60); do
    if ssh \
      -i "${KEY_FILE}" \
      -p "${SSH_PORT}" \
      -o BatchMode=yes \
      -o ConnectTimeout=2 \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      ansible@127.0.0.1 true >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done

  echo "clean-room SSH did not become ready" >&2
  docker logs "${CONTAINER_NAME}" || true
  return 1
}

up() {
  ensure_key

  docker build \
    -t "${IMAGE_NAME}" \
    -f "${ROOT_DIR}/tests/clean-room/Dockerfile" \
    "${ROOT_DIR}/tests/clean-room"

  docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true

  docker run -d \
    --name "${CONTAINER_NAME}" \
    --hostname korp-clean-room \
    --privileged \
    --cgroupns=host \
    -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
    -p "${SSH_PORT}:22" \
    -p "${HTTP_PORT}:80" \
    "${IMAGE_NAME}" >/dev/null

  docker cp "${KEY_FILE}.pub" "${CONTAINER_NAME}:/tmp/korp-clean-room-authorized-key"
  docker exec "${CONTAINER_NAME}" bash -lc \
    'install -o ansible -g ansible -m 0600 /tmp/korp-clean-room-authorized-key /home/ansible/.ssh/authorized_keys && rm -f /tmp/korp-clean-room-authorized-key'

  wait_for_ssh
  echo "clean-room ready: ssh ansible@127.0.0.1 -p ${SSH_PORT}"
}

ping_target() {
  ensure_key
  cd "${ROOT_DIR}/ansible"
  ANSIBLE_PRIVATE_KEY_FILE="${KEY_FILE}" \
    ansible -i inventories/clean-room.ini korp -m ping
}

provision() {
  ensure_key
  cd "${ROOT_DIR}/ansible"

  ansible-galaxy collection install -r requirements.yml

  ANSIBLE_PRIVATE_KEY_FILE="${KEY_FILE}" \
    ansible-playbook -i inventories/clean-room.ini site.yml
}

validate() {
  curl --fail --silent --show-error "http://127.0.0.1:${HTTP_PORT}/projeto-korp"
  echo

  if curl --fail --silent --show-error "http://127.0.0.1:8080/projeto-korp" >/dev/null 2>&1; then
    echo "unexpected direct host exposure on port 8080" >&2
    return 1
  fi

  docker exec "${CONTAINER_NAME}" bash -lc \
    'docker network inspect projeto-korp >/dev/null && docker compose -f /opt/projeto-korp/compose.yaml ps'
}

idempotence() {
  ensure_key
  cd "${ROOT_DIR}/ansible"
  ANSIBLE_PRIVATE_KEY_FILE="${KEY_FILE}" \
    ansible-playbook -i inventories/clean-room.ini site.yml
}

test_all() {
  up
  ping_target
  provision
  validate
  idempotence
  validate
}

down() {
  docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
}

case "${1:-}" in
  up) up ;;
  ping) ping_target ;;
  provision) provision ;;
  validate) validate ;;
  idempotence) idempotence ;;
  test) test_all ;;
  down) down ;;
  *)
    echo "usage: $0 {up|ping|provision|validate|idempotence|test|down}" >&2
    exit 2
    ;;
esac
