const assert = require("node:assert/strict");
const fs = require("node:fs");
const http = require("node:http");
const os = require("node:os");
const path = require("node:path");
const { chromium } = require("playwright");

const ROOT = path.resolve("web-edition/build/save-probe");
const HOST = "127.0.0.1";
const PORT = 4190;
const BASE_URL = "http://" + HOST + ":" + PORT;

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
        : path.resolve(ROOT, "." + decoded);

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

function trackPage(page, runtimeErrors, externalRequests) {
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
}

async function openPage(context) {
  const pages = context.pages();
  return pages.length > 0 ? pages[0] : await context.newPage();
}

async function waitForProbeStatus(page, expected) {
  await page.waitForFunction(
    status => document.documentElement.getAttribute("data-ghibli-save-probe") === status,
    expected,
    { timeout: 90000 }
  );
}

async function waitForGameCanvas(page) {
  await page.waitForSelector("canvas", { state: "visible", timeout: 90000 });
  await page.waitForFunction(() => {
    const canvas = document.querySelector("canvas");
    return !!canvas && canvas.width > 0 && canvas.height > 0 && !!canvas.getContext("webgl2");
  }, { timeout: 30000 });
}

async function main() {
  assert.ok(fs.existsSync(path.join(ROOT, "index.html")), "Missing Web save-probe export index.html");
  const userDataDir = fs.mkdtempSync(path.join(os.tmpdir(), "gta-ghibli-web-profile-"));
  const server = createServer();
  await new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(PORT, HOST, resolve);
  });

  const launchOptions = {
    headless: true,
    viewport: { width: 1280, height: 720 },
    args: ["--enable-webgl", "--ignore-gpu-blocklist", "--use-gl=angle", "--use-angle=swiftshader", "--no-sandbox"]
  };
  const runtimeErrors = [];
  const externalRequests = [];
  let context = null;

  try {
    context = await chromium.launchPersistentContext(userDataDir, launchOptions);
    const writePage = await openPage(context);
    trackPage(writePage, runtimeErrors, externalRequests);

    const indexedDbAvailable = await writePage.evaluate(() =>
      typeof indexedDB !== "undefined" && typeof indexedDB.open === "function"
    );
    assert.equal(indexedDbAvailable, true, "Chromium IndexedDB is unavailable in the persistent profile");

    const writeResponse = await writePage.goto(BASE_URL + "/?save_probe=write", {
      waitUntil: "domcontentloaded",
      timeout: 30000
    });
    assert.equal(writeResponse && writeResponse.status(), 200, "Write probe did not return HTTP 200");
    await waitForGameCanvas(writePage);
    await waitForProbeStatus(writePage, "written");
    const persistentAfterWrite = await writePage.locator("html").getAttribute("data-ghibli-userfs-persistent");
    assert.equal(persistentAfterWrite, "true", "Godot did not report persistent user:// storage before browser restart");
    await writePage.waitForTimeout(1500);
    await context.close();
    context = null;

    context = await chromium.launchPersistentContext(userDataDir, launchOptions);
    const readPage = await openPage(context);
    trackPage(readPage, runtimeErrors, externalRequests);
    const readResponse = await readPage.goto(BASE_URL + "/?save_probe=read", {
      waitUntil: "domcontentloaded",
      timeout: 30000
    });
    assert.equal(readResponse && readResponse.status(), 200, "Read probe did not return HTTP 200");
    await waitForGameCanvas(readPage);
    await waitForProbeStatus(readPage, "restored");
    const persistentAfterRestart = await readPage.locator("html").getAttribute("data-ghibli-userfs-persistent");
    assert.equal(persistentAfterRestart, "true", "Godot did not report persistent user:// storage after browser process restart");

    const cleanupResponse = await readPage.goto(BASE_URL + "/?save_probe=cleanup", {
      waitUntil: "domcontentloaded",
      timeout: 30000
    });
    assert.equal(cleanupResponse && cleanupResponse.status(), 200, "Cleanup probe did not return HTTP 200");
    await waitForProbeStatus(readPage, "cleaned");

    assert.deepEqual(externalRequests, [], "The browser-restart probe requested an external network resource");
    assert.deepEqual(runtimeErrors, [], "The browser reported errors during the profile restart probe");
    console.log("PASS: the live game wrote its save into a dedicated Chromium persistent profile.");
    console.log("PASS: the Chromium browser process was closed and relaunched with the same profile directory.");
    console.log("PASS: the new process restored player, mission, vehicle, inventory, NPC and world state.");
    console.log("PASS: Godot reported persistent user:// storage before and after process restart.");
    console.log("PASS: the temporary autosave slot was removed from the profile after verification.");
    console.log("PASS: no external network requests or browser runtime errors occurred.");
  } finally {
    if (context) await context.close();
    await new Promise(resolve => server.close(resolve));
    fs.rmSync(userDataDir, { recursive: true, force: true });
  }
}

main().catch(error => {
  console.error("FAIL: Web Edition browser-profile restart persistence test.");
  console.error(error && error.stack ? error.stack : error);
  process.exitCode = 1;
});
