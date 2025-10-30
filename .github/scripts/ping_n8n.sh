#!/usr/bin/env bash
set -euo pipefail
command -v openssl >/dev/null || { echo "openssl missing"; exit 2; }
command -v curl >/dev/null || { echo "curl missing"; exit 2; }
URL="${N8N_WEBHOOK_URL:?missing N8N_WEBHOOK_URL}"
SECRET="${N8N_WEBHOOK_SECRET:?missing N8N_WEBHOOK_SECRET}"
now_iso() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
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
  "status": "${GITHUB_JOB:-}",
  "timestamp": "$(now_iso)"
}
JSON
)
sig="sha256=$(printf "%s" "$payload" | openssl dgst -sha256 -hmac "$SECRET" -binary | xxd -p -c 256)"
for i in 0 3 9 27; do
  sleep "$i"
  code=$(curl -s -o /dev/null -w "%{http_code}" -H "Content-Type: application/json" -H "X-Signature: $sig" --data "$payload" "$URL" || true)
  echo "n8n try#$i -> HTTP $code"
  [[ "$code" =~ ^(200|202)$ ]] && exit 0
done
exit 1
