#!/usr/bin/env bash
set -euo pipefail

KEY=/tmp/vcas_key
SOURCE_KEY=/mnt/f/codex/.tmp/autodl-labeling/id_ed25519
KNOWN=/mnt/f/codex/.tmp/autodl-labeling/known_hosts
HOST="${AUTODL_HOST:?Set AUTODL_HOST to user@host}"
PORT="${AUTODL_PORT:?Set AUTODL_PORT}"
LOG=/root/autodl-tmp/vcas/runs/attributes/ATTR-STAGE211-INATRC-TOLL-HARDCLASS-R1/ATTR-STAGE211-BODY-CONVNEXT-256-INATRC-HARDCLASS-R1/training_log.jsonl

cp "${SOURCE_KEY}" "${KEY}"
chmod 600 "${KEY}"

for attempt in $(seq 1 24); do
  result=$(ssh -i "${KEY}" -p "${PORT}" -o BatchMode=yes -o ConnectTimeout=10 \
    -o StrictHostKeyChecking=yes -o UserKnownHostsFile="${KNOWN}" "${HOST}" \
    "if test -s '${LOG}'; then echo EPOCH_READY; tail -n 1 '${LOG}'; elif pgrep -f '[t]rain_attribute.py .*stage211-inatrc-toll-hardclass' >/dev/null; then echo RUNNING; else echo PROCESS_ENDED; fi")
  printf '%s %s\n' "$(date -Iseconds)" "${result}"
  case "${result}" in
    EPOCH_READY*|PROCESS_ENDED*) exit 0 ;;
  esac
  sleep 45
done

echo MONITOR_TIMEOUT
