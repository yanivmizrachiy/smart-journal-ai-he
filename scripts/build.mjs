import { build } from "esbuild";
import { cpSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
mkdirSync("dist", { recursive: true });
await build({
  entryPoints: ["app/main.tsx"],
  bundle: true,
  format: "esm",
  outfile: "dist/bundle.js",
  loader: { ".ts": "ts", ".tsx": "tsx" },
  minify: true
});
cpSync("public", "dist", { recursive: true });
const html = readFileSync("index.html", "utf8").replace("/app/main.tsx", "/bundle.js");
writeFileSync("dist/index.html", html);
