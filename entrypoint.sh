#!/usr/bin/env bash
set -e

# ==========================================
# Default Environment Variables
# ==========================================

CODE_SERVER_PORT=${CODE_SERVER_PORT:-8080}
CODE_SERVER_HOST=${CODE_SERVER_HOST:-0.0.0.0}
CODE_SERVER_AUTH=${CODE_SERVER_AUTH:-password}
CODE_SERVER_PASSWORD=${CODE_SERVER_PASSWORD:-admin123}
APP_DIR=${APP_DIR:-/app}

echo "======================================="
echo "🚀 Container Starting..."
echo "📂 App Dir: $APP_DIR"
echo "🌐 FrankenPHP → Port 80 (HTTP)"
echo "💻 Code Server → Port $CODE_SERVER_PORT"
echo "======================================="

mkdir -p "$APP_DIR"

export PASSWORD="$CODE_SERVER_PASSWORD"

# ------------------------------------------
# Start code-server (background)
# ------------------------------------------
echo "🔵 Starting code-server..."

code-server \
  --bind-addr ${CODE_SERVER_HOST}:${CODE_SERVER_PORT} \
  --auth ${CODE_SERVER_AUTH} \
  "$APP_DIR" &

CODE_SERVER_PID=$!

# ------------------------------------------
# Start FrankenPHP (foreground style control)
# ------------------------------------------
echo "🟢 Starting FrankenPHP..."

frankenphp run --config /etc/frankenphp/Caddyfile &

FRANKENPHP_PID=$!

# ------------------------------------------
# Graceful shutdown handler
# ------------------------------------------
shutdown() {
    echo ""
    echo "🛑 Shutting down services..."

    if kill -0 "$CODE_SERVER_PID" 2>/dev/null; then
        kill -TERM "$CODE_SERVER_PID"
        wait "$CODE_SERVER_PID"
    fi

    if kill -0 "$FRANKENPHP_PID" 2>/dev/null; then
        kill -TERM "$FRANKENPHP_PID"
        wait "$FRANKENPHP_PID"
    fi

    echo "✅ All services stopped."
    exit 0
}

trap shutdown SIGTERM SIGINT

wait -n
shutdown
