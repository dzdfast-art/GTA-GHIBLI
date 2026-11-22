const assert = require("node:assert/strict");
const fs = require("node:fs");
const http = require("node:http");
const path = require("node:path");
const { chromium } = require("playwright");

const ROOT = path.resolve("web-edition/build/web");
const HOST = "127.0.0.1";
const PORT = 4187;
const BASE_URL = `http://${HOST}:${PORT}`;

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".wasm": "application/wasm",
  ".pck": "application/octet-stream",
  ".png": "image/png",
  ".svg": "image/svg+xml",
  ".json": "application/json"
};

function createServer() {
  return http.createServer((request, response) => {
    try {
      const requestUrl = new URL(request.url || "/", BASE_URL);
      const decoded = decodeURIComponent(requestUrl.pathname);
      const file = decoded === "/"
        ? path.join(ROOT, "index.html")
        : path.resolve(ROOT, `.${decoded}`);

      if (file !== path.join(ROOT, "index.html") && !file.startsWith(ROOT + path.sep)) {
        response.writeHead(403).end("Forbidden");
        return;
      }
      if (!fs.existsSync(file) || !fs.statSync(file).isFile()) {
        response.writeHead(404).end("Not found");
        return;
      }
      response.writeHead(200, {
        "Content-Type": MIME[path.extname(file).toLowerCase()] || "application/octet-stream",
        "Cache-Control": "no-store",
        "X-Content-Type-Options": "nosniff"
      });
      if (request.method === "HEAD") {
        response.end();
        return;
      }
      fs.createReadStream(file).pipe(response);
    } catch (_error) {
      response.writeHead(400).end("Bad request");
    }
  });
}

async function main() {
  assert.ok(fs.existsSync(path.join(ROOT, "index.html")), "Missing Web export index.html");
  const server = createServer();
  await new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(PORT, HOST, resolve);
  });

  let browser;
  try {
    browser = await chromium.launch({
      headless: true,
      args: ["--enable-webgl", "--ignore-gpu-blocklist", "--use-gl=angle", "--use-angle=swiftshader", "--no-sandbox"]
    });
    const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });
    const runtimeErrors = [];
    const externalRequests = [];
    page.on("pageerror", error => runtimeErrors.push(error.message));
    page.on("console", message => {
      if (message.type() === "error") runtimeErrors.push(message.text());
    });
    page.on("request", request => {
      const requestUrl = new URL(request.url());
      if (requestUrl.hostname !== HOST && requestUrl.hostname !== "localhost") {
        externalRequests.push(request.url());
      }
    });
    await page.addInitScript(() => {
      window.addEventListener("contextmenu", event => event.preventDefault());
    });

    const response = await page.goto(BASE_URL, { waitUntil: "domcontentloaded", timeout: 30000 });
    assert.equal(response && response.status(), 200, "Web game did not return HTTP 200");
    await page.waitForSelector("canvas", { state: "visible", timeout: 90000 });
    await page.waitForFunction(() => {
      const canvas = document.querySelector("canvas");
      return !!canvas && canvas.width > 0 && canvas.height > 0;
    }, { timeout: 30000 });
    await page.waitForTimeout(10000);

    const renderState = await page.evaluate(() => {
      const canvas = document.querySelector("canvas");
      if (!canvas) return { canvas: false, webgl2: false };
      return {
        canvas: true,
        width: canvas.width,
        height: canvas.height,
        webgl2: !!canvas.getContext("webgl2"),
        title: document.title
      };
    });
    assert.ok(renderState.canvas && renderState.width > 0 && renderState.height > 0, "Godot canvas was not initialized");
    assert.ok(renderState.webgl2, "WebGL 2 context is not available");

    await page.mouse.click(640, 360);
    await page.keyboard.down("w");
    await page.waitForTimeout(350);
    await page.keyboard.up("w");
    await page.mouse.move(600, 350);
    await page.mouse.down({ button: "right" });
    await page.mouse.move(645, 350, { steps: 4 });
    await page.mouse.up({ button: "right" });
    await page.keyboard.press("m");
    await page.waitForTimeout(500);

    assert.deepEqual(externalRequests, [], "The game requested an external network resource");
    assert.deepEqual(runtimeErrors, [], "The browser reported JavaScript/runtime errors");
    await page.screenshot({ path: "/tmp/gta-ghibli-web-edition-smoke.png" });

    console.log("PASS: fresh Web export served from 127.0.0.1.");
    console.log("PASS: Godot canvas and WebGL 2 initialized: " + JSON.stringify(renderState));
    console.log("PASS: WASD, right-mouse drag and map-key input events were delivered.");
    console.log("PASS: no external network requests and no browser runtime errors.");
    console.log("NOTE: browser smoke test is not full-game or cross-browser acceptance.");
  } finally {
    if (browser) await browser.close();
    await new Promise(resolve => server.close(resolve));
  }
}

main().catch(error => {
  console.error("FAIL: Web Edition Chromium smoke test.");
  console.error(error && error.stack ? error.stack : error);
  process.exitCode = 1;
});
