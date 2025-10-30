import { mkdirSync, copyFileSync, readdirSync, readFileSync, writeFileSync } from "fs";
mkdirSync("dist", { recursive: true });
for (const f of readdirSync("public")) copyFileSync("public/"+f, "dist/"+f);
const html = readFileSync("index.html", "utf8").replace("app/main.tsx", "bundle.js");
writeFileSync("dist/index.html", html);
writeFileSync("dist/bundle.js", `
(() => {
  const root = document.getElementById("root");
  root.innerHTML = "<h1 dir=rtl>היומן החכם — גרסה קלה ל-Termux</h1><p>✨ נבנה בהצלחה ב-${new Date().toLocaleString("he-IL")}</p>";
})();
`);
