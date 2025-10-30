#!/bin/sh
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATA=event:demo
SIG="sha256=$(printf "%s.%s" "$TS" "$DATA" | openssl dgst -sha256 -hmac "$N8N_WEBHOOK_SECRET" -binary | xxd -p -c 256)"
curl -i -X POST "$N8N_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -H "X-Signature: $SIG" \
  -H "X-Timestamp: $TS" \
  -H "Idempotency-Key: $(uuidgen)" \
  --data "$DATA"
