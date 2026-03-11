#!/usr/bin/env node

const net = require("node:net");

function parseNumber(value, fallback) {
  const parsed = Number.parseInt(String(value ?? ""), 10);
  return Number.isFinite(parsed) ? parsed : fallback;
}

const listenHost = process.env.OPENCLAW_CDP_RELAY_HOST || "0.0.0.0";
const listenPort = parseNumber(process.env.OPENCLAW_CDP_RELAY_PORT, 9224);
const targetHost = process.env.OPENCLAW_CDP_TARGET_HOST || "127.0.0.1";
const targetPort = parseNumber(process.env.OPENCLAW_CDP_TARGET_PORT, 9223);

const server = net.createServer((clientSocket) => {
  const upstreamSocket = net.connect({
    host: targetHost,
    port: targetPort,
  });

  const closeBoth = () => {
    if (!clientSocket.destroyed) {
      clientSocket.destroy();
    }
    if (!upstreamSocket.destroyed) {
      upstreamSocket.destroy();
    }
  };

  clientSocket.on("error", closeBoth);
  upstreamSocket.on("error", closeBoth);
  clientSocket.on("close", closeBoth);
  upstreamSocket.on("close", closeBoth);

  clientSocket.pipe(upstreamSocket);
  upstreamSocket.pipe(clientSocket);
});

server.on("error", (error) => {
  console.error(`[openclaw-cdp-relay] ${String(error)}`);
  process.exitCode = 1;
});

server.listen(listenPort, listenHost, () => {
  console.log(
    `[openclaw-cdp-relay] listening on ${listenHost}:${listenPort} -> ${targetHost}:${targetPort}`,
  );
});
