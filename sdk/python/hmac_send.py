import os, hmac, hashlib, uuid, json, requests, datetime
url=os.environ["N8N_WEBHOOK_URL"]
secret=os.environ["N8N_WEBHOOK_SECRET"].encode()
payload=json.dumps({"event":"demo","payload":{"x":1}})
ts=datetime.datetime.utcnow().isoformat()+"Z"
toSign=(ts+"."+payload).encode()
sig=b"sha256="+hmac.new(secret,toSign,hashlib.sha256).hexdigest().encode()
res=requests.post(url,headers={"Content-Type":"application/json","X-Signature":sig,"X-Timestamp":ts,"Idempotency-Key":str(uuid.uuid4())},data=payload)
print(res.status_code,res.text)
