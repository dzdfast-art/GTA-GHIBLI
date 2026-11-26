const assert = require("node:assert/strict");
const fs = require("node:fs");
const http = require("node:http");
const path = require("node:path");
const { chromium } = require("playwright");

const ROOT = path.resolve("web-edition/build/save-probe");
const HOST = "127.0.0.1";
const PORT = 4189;
const BASE_URL = \`http://\${HOST}:\${PORT}\`;
const SESSION_ONLY_MESSAGE = "SESSION ONLY — allow browser storage";
const SAVE_FAILED_MESSAGE = "SAVE FAILED — check browser storage";

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
        : path.resolve(ROOT, \`.\${decoded}\`);

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

async function waitForProbeStatus(page, expected) {
  await page.waitForFunction(
    status => document.documentElement.getAttribute("data-ghibli-save-probe") === status,
    expected,
    { timeout: 90000 }
  );
}

async function main() {
  assert.ok(fs.existsSync(path.join(ROOT, "index.html")), "Missing Web save-probe export index.html");
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
    const context = await browser.newContext({ viewport: { width: 1280, height: 720 } });
    await context.addInitScript(() => {
      const descriptor = Object.getOwnPropertyDescriptor(window, "indexedDB");
      Object.defineProperty(window, "indexedDB", {
        configurable: true,
        enumerable: descriptor ? descriptor.enumerable : true,
        value: undefined,
        writable: false
      });
    });

    const page = await context.newPage();
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

    const response = await page.goto(\`\${BASE_URL}/?save_probe=session\`, {
      waitUntil: "domcontentloaded",
      timeout: 30000
    });
    assert.equal(response && response.status(), 200, "Session-only probe export did not return HTTP 200");

    const indexedDbType = await page.evaluate(() => typeof window.indexedDB);
    assert.equal(indexedDbType, "undefined", "The test did not successfully block IndexedDB before game startup");

    await page.waitForSelector("canvas", { state: "visible", timeout: 90000 });
    await page.waitForFunction(() => {
      const canvas = document.querySelector("canvas");
      return !!canvas && canvas.width > 0 && canvas.height > 0 && !!canvas.getContext("webgl2");
    }, { timeout: 30000 });
    await waitForProbeStatus(page, "session_only");

    const persistent = await page.locator("html").getAttribute("data-ghibli-userfs-persistent");
    assert.equal(persistent, "false", "Godot still reports persistent user:// storage after IndexedDB was blocked");

    const saveSucceeded = await page.locator("html").getAttribute("data-ghibli-save-succeeded");
    const saveStatus = await page.locator("html").getAttribute("data-ghibli-save-status");
    if (saveSucceeded === "true") {
      assert.equal(saveStatus, SESSION_ONLY_MESSAGE, "A successful non-persistent save was not labelled session-only");
      console.log("PASS: a session-only save remained readable inside the active page session.");
    } else {
      assert.equal(saveSucceeded, "false", "The probe did not publish a valid save result");
      assert.equal(saveStatus, SAVE_FAILED_MESSAGE, "A failed save was not reported explicitly.");
      console.log("PASS: an unavailable session save was reported as failed, not durable.");
    }
    assert.ok(!String(saveStatus).includes("BROWSER STORAGE"), "The HUD falsely claimed browser persistence");
    assert.ok(!String(saveStatus).includes("LOCAL SAVE"), "The Web game falsely described the save as a native local save");

    assert.deepEqual(externalRequests, [], "The session-only game requested an external network resource");
    assert.deepEqual(runtimeErrors, [], "The browser reported runtime errors while IndexedDB was blocked");
    console.log("PASS: IndexedDB was unavailable before the Godot Web runtime initialized.");
    console.log("PASS: Godot reported user:// as non-persistent and the HUD made no durable-storage claim.");
    console.log("PASS: the game retained its WebGL 2 canvas and completed the storage-status probe.");
    console.log("PASS: no external network requests or browser runtime errors occurred.");
    await context.close();
  } finally {
    if (browser) await browser.close();
    await new Promise(resolve => server.close(resolve));
  }
}

main().catch(error => {
  console.error("FAIL: Web Edition blocked-IndexedDB session-only test.");
  console.error(error && error.stack ? error.stack : error);
  process.exitCode = 1;
});
