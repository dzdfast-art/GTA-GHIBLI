const assert = require("node:assert/strict");
const fs = require("node:fs");
const http = require("node:http");
const path = require("node:path");
const { chromium } = require("playwright");

const ROOT = path.resolve("build/web");
const HOST = "127.0.0.1";
const PORT = 4173;
const BASE_URL = `http://${HOST}:${PORT}`;

const mimeTypes = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".wasm": "application/wasm",
  ".pck": "application/octet-stream",
  ".png": "image/png",
  ".svg": "image/svg+xml",
  ".ogg": "audio/ogg",
  ".wav": "audio/wav",
  ".json": "application/json",
  ".ico": "image/x-icon",
};

function createLocalServer() {
  return http.createServer((request, response) => {
    try {
      const requestUrl = new URL(request.url || "/", BASE_URL);
      if (requestUrl.pathname === "/favicon.ico") {
        response.writeHead(204).end();
        return;
      }

      const decodedPath = decodeURIComponent(requestUrl.pathname);
      const candidate = decodedPath === "/"
        ? path.join(ROOT, "index.html")
        : path.resolve(ROOT, `.${decodedPath}`);

      if (candidate !== path.join(ROOT, "index.html") &&
          !candidate.startsWith(ROOT + path.sep)) {
        response.writeHead(403).end("Forbidden");
        return;
      }

      if (!fs.existsSync(candidate) || !fs.statSync(candidate).isFile()) {
        response.writeHead(404).end("Not found");
        return;
      }

      response.writeHead(200, {
        "Content-Type": mimeTypes[path.extname(candidate).toLowerCase()] || "application/octet-stream",
        "Cache-Control": "no-store",
        "X-Content-Type-Options": "nosniff",
      });

      if (request.method === "HEAD") {
        response.end();
        return;
      }

      fs.createReadStream(candidate).pipe(response);
    } catch (error) {
      response.writeHead(400).end("Bad request");
    }
  });
}

async function main() {
  assert.ok(fs.existsSync(path.join(ROOT, "index.html")), "Web export index.html is missing");
  const server = createLocalServer();
  await new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(PORT, HOST, resolve);
  });

  let browser;
  try {
    browser = await chromium.launch({
      headless: true,
      args: [
        "--enable-webgl",
        "--ignore-gpu-blocklist",
        "--use-gl=angle",
        "--use-angle=swiftshader",
        "--disable-dev-shm-usage",
      ],
    });

    const page = await browser.newPage({
      viewport: { width: 1280, height: 720 },
      deviceScaleFactor: 1,
    });

    const runtimeErrors = [];
    const externalRequests = [];
    page.on("pageerror", error => runtimeErrors.push(error.message));
    page.on("console", message => {
      if (message.type() === "error") runtimeErrors.push(message.text());
    });
    page.on("request", request => {
      const url = new URL(request.url());
      if (url.hostname !== HOST && url.hostname !== "localhost") {
        externalRequests.push(request.url());
      }
    });

    const response = await page.goto(BASE_URL, {
      waitUntil: "domcontentloaded",
      timeout: 30000,
    });
    assert.equal(response && response.status(), 200, "Web preview did not return HTTP 200");

    await page.waitForSelector("canvas", { state: "visible", timeout: 90000 });
    await page.waitForFunction(() => {
      const canvas = document.querySelector("canvas");
      return !!canvas && canvas.width > 0 && canvas.height > 0;
    }, { timeout: 30000 });

    // Give Godot time to initialize the scene and render several frames.
    await page.waitForTimeout(12000);

    const state = await page.evaluate(() => {
      const canvas = document.querySelector("canvas");
      if (!canvas) return { canvas: false, webgl2: false };
      const context = canvas.getContext("webgl2");
      return {
        canvas: true,
        width: canvas.width,
        height: canvas.height,
        webgl2: !!context,
        documentTitle: document.title,
      };
    });

    assert.ok(state.canvas, "Godot render canvas was not created");
    assert.ok(state.width > 0 && state.height > 0, "Godot canvas has zero dimensions");
    assert.ok(state.webgl2, "WebGL 2 context is unavailable");

    // Use viewport coordinates for the real pointer event. Playwright's
    // locator actionability/stability wait can time out on an actively rendered
    // WebGL canvas even when the canvas is visible and the game is responsive.
    await page.mouse.click(640, 360);
    await page.keyboard.press("w");
    await page.waitForTimeout(1000);

    assert.deepEqual(externalRequests, [], "Web preview attempted an external network request");
    assert.deepEqual(runtimeErrors, [], "Browser reported JavaScript/runtime errors");

    await page.screenshot({ path: "/tmp/gta-ghibli-web-preview-smoke.png" });
    console.log("PASS: Web preview opened in Chromium on a local-only HTTP server.");
    console.log("PASS: Godot canvas initialized with WebGL 2: " + JSON.stringify(state));
    console.log("PASS: Browser input events were delivered without runtime errors.");
    console.log("PASS: No external network requests were made by the preview.");
    console.log("PASS: Temporary screenshot saved on the ephemeral runner only.");
  } finally {
    if (browser) await browser.close();
    await new Promise(resolve => server.close(resolve));
  }
}

main().catch(error => {
  console.error("FAIL: Web browser smoke test failed.");
  console.error(error && error.stack ? error.stack : error);
  process.exitCode = 1;
});
