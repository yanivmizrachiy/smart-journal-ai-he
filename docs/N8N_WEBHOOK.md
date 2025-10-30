# n8n Webhook Integration (GitHub CI/CD)
- כל ריצה/פוש/PR שולחת אירוע חתום ל‑n8n.
- אימות: HMAC( sha256( timestamp + . + payload ) ), חלון זמן 5 דק׳, Idempotency‑Key.
