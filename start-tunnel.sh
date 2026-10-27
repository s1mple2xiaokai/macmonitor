#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"
CLOUDFLARED_BIN="${CLOUDFLARED_BIN:-/opt/homebrew/bin/cloudflared}"
CONFIG_FILE="${CLOUDFLARED_CONFIG:-$SCRIPT_DIR/cloudflared/config.yml}"
HEALTH_URL="${HEALTH_URL:-http://localhost:8080/api/health}"

BACKEND_PID=""
TUNNEL_PID=""

cleanup() {
    local exit_code=$?
    if [ -n "$TUNNEL_PID" ] && kill -0 "$TUNNEL_PID" 2>/dev/null; then
        kill "$TUNNEL_PID" 2>/dev/null || true
    fi
    if [ -n "$BACKEND_PID" ] && kill -0 "$BACKEND_PID" 2>/dev/null; then
        kill "$BACKEND_PID" 2>/dev/null || true
    fi
    wait 2>/dev/null || true
    exit $exit_code
}
trap cleanup EXIT INT TERM

if [ ! -x "$CLOUDFLARED_BIN" ]; then
    echo "ERROR: cloudflared not found at $CLOUDFLARED_BIN"
    echo "Set CLOUDFLARED_BIN or install cloudflared first."
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: missing config file: $CONFIG_FILE"
    echo "Create it from cloudflared/config.yml.example first."
    exit 1
fi

if [ ! -d "$BACKEND_DIR" ]; then
    echo "ERROR: backend directory not found: $BACKEND_DIR"
    exit 1
fi

echo "Starting Go backend..."
(
    cd "$BACKEND_DIR"
    go run . >/tmp/macmonitor-backend.log 2>&1
) &
BACKEND_PID=$!

echo "Waiting for backend health endpoint..."
for _ in $(seq 1 30); do
    if curl -fsS "$HEALTH_URL" >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

if ! curl -fsS "$HEALTH_URL" >/dev/null 2>&1; then
    echo "ERROR: backend did not become healthy at $HEALTH_URL"
    echo "Backend log: /tmp/macmonitor-backend.log"
    exit 1
fi

echo "Backend is healthy."
echo "Starting Cloudflare Tunnel..."
"$CLOUDFLARED_BIN" tunnel --config "$CONFIG_FILE" run >/tmp/macmonitor-cloudflared.log 2>&1 &
TUNNEL_PID=$!

sleep 2
if ! kill -0 "$TUNNEL_PID" 2>/dev/null; then
    echo "ERROR: cloudflared failed to start."
    echo "Tunnel log: /tmp/macmonitor-cloudflared.log"
    exit 1
fi

PUBLIC_HOSTNAME="$(awk '/hostname:/ {print $2; exit}' "$CONFIG_FILE" || true)"
echo "Tunnel is running."
echo "Local health: $HEALTH_URL"
if [ -n "$PUBLIC_HOSTNAME" ]; then
    echo "Public URL: https://$PUBLIC_HOSTNAME"
fi
echo "Logs:"
echo "  backend: /tmp/macmonitor-backend.log"
echo "  tunnel:  /tmp/macmonitor-cloudflared.log"
echo "Press Ctrl+C to stop."

wait
