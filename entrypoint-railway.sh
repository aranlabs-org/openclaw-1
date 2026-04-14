#!/bin/sh
# Railway entrypoint: fix volume permissions then start the gateway.
# Railway volumes mount as root; the container runs as uid 1000 (node).

# Create dirs if missing and fix ownership
mkdir -p /data/.openclaw /data/workspace
chown -R node:node /data

# Drop to node user and start the gateway.
# Config is read from /app/openclaw.json5 via OPENCLAW_CONFIG_PATH env var.
exec su -s /bin/sh node -c 'exec node /app/openclaw.mjs gateway --allow-unconfigured'
