#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"
CLOUDFLARED_BIN="${CLOUDFLARED_BIN:-/opt/homebrew/bin/cloudflared}"
CLOUDFLARED_CONFIG="${CLOUDFLARED_CONFIG:-$SCRIPT_DIR/cloudflared/config.yml}"
ENABLE_CLOUDFLARE="${ENABLE_CLOUDFLARE:-0}"
PORT="${PORT:-8080}"

if [ -z "${WEBTERM_TOKEN:-}" ]; then
  if command -v openssl >/dev/null 2>&1; then
    WEBTERM_TOKEN="$(openssl rand -hex 24)"
  else
    WEBTERM_TOKEN="$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 48)"
  fi
  export WEBTERM_TOKEN
  echo "Generated temporary WEBTERM_TOKEN for this run."
fi

BACKEND_PID=""
TUNNEL_PID=""

cleanup() {
  local code=$?
  if [ -n "$TUNNEL_PID" ] && kill -0 "$TUNNEL_PID" 2>/dev/null; then
    kill "$TUNNEL_PID" 2>/dev/null || true
  fi
  if [ -n "$BACKEND_PID" ] && kill -0 "$BACKEND_PID" 2>/dev/null; then
    kill "$BACKEND_PID" 2>/dev/null || true
  fi
  wait 2>/dev/null || true
  exit $code
}
trap cleanup EXIT INT TERM

echo "Starting backend on :$PORT ..."
(
  cd "$BACKEND_DIR"
  WEBTERM_TOKEN="$WEBTERM_TOKEN" PORT="$PORT" go run . >/tmp/macmonitor-backend.log 2>&1
) &
BACKEND_PID=$!

for _ in $(seq 1 30); do
  if curl -fsS "http://localhost:$PORT/api/health" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! curl -fsS "http://localhost:$PORT/api/health" >/dev/null 2>&1; then
  echo "Backend did not become healthy. Check /tmp/macmonitor-backend.log"
  exit 1
fi

echo "Backend is healthy."
echo "Local terminal URL: http://localhost:$PORT/terminal?token=$WEBTERM_TOKEN"

if [ "$ENABLE_CLOUDFLARE" = "1" ]; then
  if [ ! -x "$CLOUDFLARED_BIN" ]; then
    echo "cloudflared not found at $CLOUDFLARED_BIN"
    exit 1
  fi
  if [ ! -f "$CLOUDFLARED_CONFIG" ]; then
    echo "cloudflared config not found: $CLOUDFLARED_CONFIG"
    exit 1
  fi

  echo "Starting Cloudflare Tunnel..."
  "$CLOUDFLARED_BIN" tunnel --config "$CLOUDFLARED_CONFIG" run >/tmp/macmonitor-cloudflared.log 2>&1 &
  TUNNEL_PID=$!
  sleep 2

  if ! kill -0 "$TUNNEL_PID" 2>/dev/null; then
    echo "Cloudflare tunnel failed. Check /tmp/macmonitor-cloudflared.log"
    exit 1
  fi

  HOSTNAME="$(awk '/hostname:/ {print $2; exit}' "$CLOUDFLARED_CONFIG" || true)"
  if [ -n "$HOSTNAME" ]; then
    echo "Public terminal URL: https://$HOSTNAME/terminal?token=$WEBTERM_TOKEN"
  fi
fi

echo "Logs:"
echo "  backend: /tmp/macmonitor-backend.log"
if [ "$ENABLE_CLOUDFLARE" = "1" ]; then
  echo "  tunnel:  /tmp/macmonitor-cloudflared.log"
fi

echo "Press Ctrl+C to stop."
wait
