#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="${ROOT_DIR}/.tmp/ansible-clean-room"
KEY_FILE="${STATE_DIR}/id_ed25519"
CONTAINER_NAME="korp-ansible-clean-room"
IMAGE_NAME="korp-ansible-clean-room:local"
SSH_PORT="${KORP_CLEAN_ROOM_SSH_PORT:-2222}"
HTTP_PORT="${KORP_CLEAN_ROOM_HTTP_PORT:-8088}"
CONTROL_IMAGE="korp-ansible-clean-room-control:local"
CONTROL_DOCKERFILE="${ROOT_DIR}/tests/clean-room/control-node.Dockerfile"
# Por padrao o Ansible roda no control node conteinerizado, para que a
# validacao nao dependa do que esta instalado no host nem da versao local.
# KORP_CLEAN_ROOM_LOCAL_ANSIBLE=1 usa o Ansible do host.
USE_LOCAL_ANSIBLE="${KORP_CLEAN_ROOM_LOCAL_ANSIBLE:-0}"

require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is required to run the clean-room validation." >&2
    echo "Install Docker Engine with the Compose plugin, then run: make ansible-clean-room-test" >&2
    return 1
  fi

  if ! docker info >/dev/null 2>&1; then
    echo "Docker is installed, but the daemon is not reachable by this user." >&2
    echo "Start Docker and confirm this user can run: docker info" >&2
    return 1
  fi
}

ensure_key() {
  mkdir -p "${STATE_DIR}"
  if [[ ! -f "${KEY_FILE}" ]]; then
    ssh-keygen -q -t ed25519 -N "" -f "${KEY_FILE}" -C "korp-clean-room"
  fi
}

build_control_node() {
  require_docker

  docker build \
    -t "${CONTROL_IMAGE}" \
    -f "${CONTROL_DOCKERFILE}" \
    "${ROOT_DIR}/tests/clean-room" >/dev/null
}

# Executa um comando do Ansible contra o clean-room.
#
# --network host e necessario porque o inventario aponta para 127.0.0.1:2222,
# que e a porta publicada pelo container alvo no host. O socket do Docker entra
# para que as tasks que falam com a API do Docker funcionem do mesmo jeito que
# funcionariam a partir do host.
#
# O container roda com o uid/gid do host para nao deixar arquivos de root em
# .tmp/. Isso exige montar /etc/passwd e /etc/group em read-only: o cliente SSH
# resolve o uid via getpwuid e falha com "No user exists for uid" sem isso.
ansible_exec() {
  if [[ "${USE_LOCAL_ANSIBLE}" == "1" ]]; then
    ( cd "${ROOT_DIR}/ansible" \
      && ANSIBLE_PRIVATE_KEY_FILE="${KEY_FILE}" "$@" )
    return
  fi

  build_control_node

  local docker_gid
  docker_gid="$(stat -c '%g' /var/run/docker.sock)"

  docker run --rm \
    --network host \
    --user "$(id -u):$(id -g)" \
    --group-add "${docker_gid}" \
    -e HOME=/tmp \
    -e ANSIBLE_PRIVATE_KEY_FILE=/repo/.tmp/ansible-clean-room/id_ed25519 \
    -e ANSIBLE_COLLECTIONS_PATH=/repo/.tmp/ansible-clean-room/collections \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /etc/passwd:/etc/passwd:ro \
    -v /etc/group:/etc/group:ro \
    -v "${ROOT_DIR}:/repo" \
    -w /repo/ansible \
    "${CONTROL_IMAGE}" "$@"
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
  require_docker
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
  ansible_exec ansible -i inventories/clean-room.ini korp -m ping
}

provision() {
  ensure_key
  ansible_exec ansible-galaxy collection install -r requirements.yml
  ansible_exec ansible-playbook -i inventories/clean-room.ini site.yml
}

validate() {
  require_docker

  curl --fail --silent --show-error "http://127.0.0.1:${HTTP_PORT}/projeto-korp"
  echo

  if curl --fail --silent --show-error "http://127.0.0.1:8080/projeto-korp" >/dev/null 2>&1; then
    echo "unexpected direct host exposure on port 8080" >&2
    return 1
  fi

  docker exec "${CONTAINER_NAME}" bash -lc \
    'docker network inspect projeto-korp >/dev/null && docker compose -f /opt/projeto-korp/compose.yaml ps'
}

# Uma segunda execucao precisa terminar com changed=0. Rodar de novo sem
# verificar o recap nao prova idempotencia, so que o playbook nao quebra.
idempotence() {
  ensure_key
  local recap_log="${STATE_DIR}/idempotence.log"
  ansible_exec ansible-playbook -i inventories/clean-room.ini site.yml \
    | tee "${recap_log}"

  local changed
  changed="$(sed -n 's/.*changed=\([0-9][0-9]*\).*/\1/p' "${recap_log}" | tail -1)"
  if [[ -z "${changed}" ]]; then
    echo "could not read changed count from the Ansible recap" >&2
    return 1
  fi
  if [[ "${changed}" != "0" ]]; then
    echo "second run reported changed=${changed}, expected 0" >&2
    return 1
  fi
  echo "idempotence: second run reported changed=0"
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
  require_docker

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
