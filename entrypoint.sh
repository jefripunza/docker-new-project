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
INIT_FRAMEWORK=${INIT_FRAMEWORK:-}

echo "======================================="
echo "🚀 Container Starting..."
echo "📂 App Dir: $APP_DIR"
echo "🌐 FrankenPHP → Port 80 (HTTP)"
echo "💻 Code Server → Port $CODE_SERVER_PORT"
echo "======================================="

mkdir -p "$APP_DIR"

export PASSWORD="$CODE_SERVER_PASSWORD"

# ------------------------------------------
# Framework Initialization (if needed)
# ------------------------------------------
if [ -n "$INIT_FRAMEWORK" ]; then
  # Check if /app is empty (only . and .. exist)
  if [ -z "$(ls -A $APP_DIR)" ]; then
    echo "📦 Initializing framework: $INIT_FRAMEWORK"
    
    case "$INIT_FRAMEWORK" in
      ci4|codeigniter4)
        echo "🔧 Installing CodeIgniter 4..."
        composer create-project codeigniter4/appstarter /tmp/ci4 --no-interaction
        cp -R /tmp/ci4/. "$APP_DIR"
        rm -rf /tmp/ci4
        chown -R www-data:www-data "$APP_DIR"
        chmod -R 775 "$APP_DIR/writable"
        echo "✅ CodeIgniter 4 installed"
        ;;
      
      laravel12|laravel)
        echo "🔧 Installing Laravel 12..."
        composer create-project laravel/laravel /tmp/laravel --no-interaction
        cp -R /tmp/laravel/. "$APP_DIR"
        rm -rf /tmp/laravel
        chown -R www-data:www-data "$APP_DIR"
        chmod -R 775 "$APP_DIR/storage" "$APP_DIR/bootstrap/cache"
        echo "✅ Laravel installed"
        ;;
      
      *)
        echo "⚠️  Unknown framework: $INIT_FRAMEWORK"
        echo "    Supported: ci4, codeigniter4, laravel12, laravel"
        ;;
    esac
  else
    echo "📁 /app is not empty, skipping framework initialization"
    echo "   Using existing project"
  fi
else
  echo "ℹ️  INIT_FRAMEWORK not set, skipping framework initialization"

  if [ ! -f "$APP_DIR/public/index.php" ]; then
    echo "🧩 No framework selected. Creating default $APP_DIR/public/index.php (phpinfo)"
    mkdir -p "$APP_DIR/public"
    cat > "$APP_DIR/public/index.php" <<'PHP'
<?php
phpinfo();
PHP
    chown -R www-data:www-data "$APP_DIR/public"
  fi
fi

# ------------------------------------------
# Start code-server (background)
# ------------------------------------------
echo "🔵 Starting code-server..."

# Unset PORT to prevent code-server from using it (FrankenPHP may set PORT=80)
unset PORT

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
