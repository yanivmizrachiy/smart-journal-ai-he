#!/usr/bin/env bash
set -euo pipefail
command -v openssl >/dev/null || { echo "openssl missing"; exit 2; }
command -v curl >/dev/null || { echo "curl missing"; exit 2; }
URL="${N8N_WEBHOOK_URL:?missing N8N_WEBHOOK_URL}"
SECRET="${N8N_WEBHOOK_SECRET:?missing N8N_WEBHOOK_SECRET}"
IDEMPOTENCY_KEY=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid)
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
UA="smart-github-hub/1.0 (+actions)"

payload=$(cat <<JSON
{
  "repo": "${GITHUB_REPOSITORY:-}",
  "workflow": "${GITHUB_WORKFLOW:-}",
  "run_id": "${GITHUB_RUN_ID:-}",
  "run_url": "${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID:-}",
  "actor": "${GITHUB_ACTOR:-}",
  "branch": "${GITHUB_REF_NAME:-}",
  "sha": "${GITHUB_SHA:-}",
  "event": "${GITHUB_EVENT_NAME:-}",
  "job": "${GITHUB_JOB:-}",
  "timestamp": "${TS}",
  "idempotency": "${IDEMPOTENCY_KEY}"
}
JSON
)

sig_body="${TS}.${payload}"
sig="sha256=$(printf "%s" "$sig_body" | openssl dgst -sha256 -hmac "$SECRET" -binary | xxd -p -c 256)"

attempts=(0 2 4 8 16)
for i in "${!attempts[@]}"; do
  sleep $(( attempts[$i] + RANDOM % 3 ))
  code=$(curl -s -o /tmp/n8n_resp.json -w "%{http_code}" \
    -H "Content-Type: application/json" \
    -H "User-Agent: $UA" \
    -H "X-Signature: $sig" \
    -H "X-Timestamp: $TS" \
    -H "Idempotency-Key: $IDEMPOTENCY_KEY" \
    --data "$payload" "$URL" || true)
  echo "n8n try#$i -> HTTP $code"
  [[ "$code" =~ ^(200|202)$ ]] && exit 0
  [[ "$code" =~ ^4 ]] && break
done
mkdir -p artifacts && cp -f /tmp/n8n_resp.json artifacts/n8n_last_response.json 2>/dev/null || true
exit 1
