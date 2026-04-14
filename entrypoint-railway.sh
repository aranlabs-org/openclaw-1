#!/bin/sh
# Railway entrypoint: fix volume permissions then start the gateway.
# Railway volumes mount as root; the container runs as uid 1000 (node).

# Create dirs if missing and fix ownership
mkdir -p /data/.openclaw /data/workspace
chown -R node:node /data

# Copy the bundled config to the persistent volume on every boot.
# The gateway rewrites its config file in-place, so we always restore
# our known-good config from the image before starting.
cp /app/openclaw.json5.bundled /data/.openclaw/openclaw.json
chown node:node /data/.openclaw/openclaw.json

# Drop to node user and start the gateway.
exec su -s /bin/sh node -c 'exec node /app/openclaw.mjs gateway --allow-unconfigured'
