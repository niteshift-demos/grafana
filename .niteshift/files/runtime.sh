#!/usr/bin/env bash
export PATH="/opt/grafana-node/bin:/opt/grafana-go/bin:$PATH"
export NODE_OPTIONS="--max-old-space-size=8192"
export NX_DAEMON=false
# Bound Go compiler parallelism to leave memory for the frontend watcher.
export GOFLAGS="-p=4"
