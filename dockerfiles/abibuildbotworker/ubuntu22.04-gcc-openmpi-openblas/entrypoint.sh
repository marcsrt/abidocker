#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" != "start" ]; then
    exec "$@"
fi

required_env() {
    local name="$1"
    if [ -z "${!name:-}" ]; then
        echo "Missing required environment variable: ${name}" >&2
        exit 2
    fi
}

required_env WORKER_NAME
required_env MASTER_HOST
required_env MASTER_PORT

if [ -n "${WORKER_PASSWORD_FILE:-}" ]; then
    WORKER_PASSWORD="$(cat "${WORKER_PASSWORD_FILE}")"
fi

if [ -z "${WORKER_PASSWORD:-}" ]; then
    echo "Missing required environment variable: WORKER_PASSWORD or WORKER_PASSWORD_FILE" >&2
    exit 2
fi

WORKER_BASEDIR="${WORKER_BASEDIR:-/buildbot-worker}"
MASTER_ENDPOINT="${MASTER_HOST}:${MASTER_PORT}"

mkdir -p "${WORKER_BASEDIR}"

if [ ! -f "${WORKER_BASEDIR}/buildbot.tac" ]; then
    buildbot-worker create-worker "${WORKER_BASEDIR}" "${MASTER_ENDPOINT}" "${WORKER_NAME}" "${WORKER_PASSWORD}"
fi

exec buildbot-worker start --nodaemon "${WORKER_BASEDIR}"
