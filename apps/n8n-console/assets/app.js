async function request(event, payload){
  const url = \(event==="proxy" ? "/.github/workflows/dispatch_to_n8n.yml" : prompt("URL ל־n8n:"));
  const body = { event, payload };
  const res = await fetch(url, {
    method:"POST",
    headers:{ "Content-Type":"application/json" },
    body: JSON.stringify(body)
  });
  const txt = await res.text(); document.getElementById("output").textContent = txt;
}

document.getElementById("direct").onclick=()=>{request("direct",{hello:"world"});}
document.getElementById("proxy").onclick=()=>{request("proxy",{hello:"world"});}
