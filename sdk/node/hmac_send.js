import crypto from "crypto";
import fetch from "node-fetch";
const url = process.env.N8N_WEBHOOK_URL;
const secret = process.env.N8N_WEBHOOK_SECRET;
(async ()=>{
  const payload=JSON.stringify({ event:"demo", payload:{ x:1 }});
  const ts=new Date().toISOString();
  const sig="sha256="+crypto.createHmac("sha256",secret).update(ts+"."+payload).digest("hex");
  const res=await fetch(url, {
    method:"POST",
    headers:{
      "Content-Type":"application/json",
      "X-Signature":sig,
      "X-Timestamp":ts,
      "Idempotency-Key":crypto.randomUUID()
    },
    body:payload
  });
  console.log(res.status,await res.text());
})();
