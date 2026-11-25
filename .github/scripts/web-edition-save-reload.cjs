const assert = require("node:assert/strict");
const fs = require("node:fs");
const http = require("node:http");
const path = require("node:path");
const { chromium } = require("playwright");

const ROOT = path.resolve("web-edition/build/save-probe");
const HOST = "127.0.0.1";
const PORT = 4188;
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

    const indexedDbAvailable = await page.evaluate(() =>
      typeof indexedDB !== "undefined" && typeof indexedDB.open === "function"
    ).catch(() => false);
    assert.equal(indexedDbAvailable, true, "Chromium IndexedDB is unavailable in the test context");

    const writeResponse = await page.goto(`${BASE_URL}/?save_probe=write`, {
      waitUntil: "domcontentloaded",
      timeout: 30000
    });
    assert.equal(writeResponse && writeResponse.status(), 200, "Save-probe export did not return HTTP 200");
    await page.waitForSelector("canvas", { state: "visible", timeout: 90000 });
    await page.waitForFunction(() => {
      const canvas = document.querySelector("canvas");
      return !!canvas && canvas.width > 0 && canvas.height > 0 && !!canvas.getContext("webgl2");
    }, { timeout: 30000 });
    await waitForProbeStatus(page, "written");
    await page.waitForTimeout(1500);

    await page.evaluate(() => {
      const next = new URL(window.location.href);
      next.searchParams.set("save_probe", "read");
      history.replaceState(null, "", next.toString());
    });
    await page.reload({ waitUntil: "domcontentloaded", timeout: 30000 });
    await page.waitForSelector("canvas", { state: "visible", timeout: 90000 });
    await waitForProbeStatus(page, "restored");

    await page.evaluate(() => {
      const next = new URL(window.location.href);
      next.searchParams.set("save_probe", "cleanup");
      history.replaceState(null, "", next.toString());
    });
    await page.reload({ waitUntil: "domcontentloaded", timeout: 30000 });
    await waitForProbeStatus(page, "cleaned");

    assert.deepEqual(externalRequests, [], "The save-probe game requested an external network resource");
    assert.deepEqual(runtimeErrors, [], "The browser reported errors during the save/reload probe");
    console.log("PASS: Chromium IndexedDB is available in the persistent browser context.");
    console.log("PASS: the actual game scene saved player, mission, vehicle, inventory, NPC and world state to user://.");
    console.log("PASS: a full page reload restored that live-game state from the same browser origin.");
    console.log("PASS: the temporary autosave slot was deleted after verification.");
    console.log("PASS: no external network requests or browser runtime errors occurred.");
    console.log("NOTE: this validates Chromium page-reload persistence; blocked/private storage and other browsers remain separate gates.");
    await context.close();
  } finally {
    if (browser) await browser.close();
    await new Promise(resolve => server.close(resolve));
  }
}

main().catch(error => {
  console.error("FAIL: Web Edition browser save/reload persistence test.");
  console.error(error && error.stack ? error.stack : error);
  process.exitCode = 1;
});
