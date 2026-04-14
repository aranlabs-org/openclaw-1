#!/bin/sh
# Railway entrypoint: fix volume permissions then start the gateway.
# Railway volumes mount as root; the container runs as uid 1000 (node).

# Create dirs if missing and fix ownership (runs as root initially via Dockerfile override)
mkdir -p /data/.openclaw /data/workspace
chown -R node:node /data

# Pre-seed allowed origins for Control UI before gateway starts.
# The gateway overwrites the config file on boot, so we patch it after seeding.
RAILWAY_DOMAIN="${RAILWAY_PUBLIC_DOMAIN:-}"
if [ -n "$RAILWAY_DOMAIN" ]; then
  su -s /bin/sh node -c "node /app/openclaw.mjs config set gateway.controlUi.allowedOrigins '[\"https://$RAILWAY_DOMAIN\",\"http://localhost:18789\",\"http://127.0.0.1:18789\"]'" 2>/dev/null || true
  # Trust Railway's internal proxy so Control UI connections are treated as local.
  su -s /bin/sh node -c "node /app/openclaw.mjs config set gateway.trustedProxies '[\"100.64.0.0/10\",\"10.0.0.0/8\",\"172.16.0.0/12\"]'" 2>/dev/null || true
fi

# Set default model to Anthropic Claude — only provider with a configured key.
su -s /bin/sh node -c "node /app/openclaw.mjs config set agents.defaults.model 'anthropic/claude-sonnet-4-6'" 2>/dev/null || true

# Drop to node user and start the gateway
exec su -s /bin/sh node -c 'exec node /app/openclaw.mjs gateway --allow-unconfigured'
