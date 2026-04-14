#!/bin/sh
# Railway entrypoint: fix volume permissions then start the gateway.
# Railway volumes mount as root; the container runs as uid 1000 (node).

# Create dirs if missing and fix ownership (runs as root initially via Dockerfile override)
mkdir -p /data/.openclaw /data/workspace
chown -R node:node /data

# Drop to node user and start the gateway
exec su -s /bin/sh node -c 'exec node /app/openclaw.mjs gateway --allow-unconfigured'
