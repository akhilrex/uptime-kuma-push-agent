#!/bin/sh

# Uptime Kuma Push Agent
# Sends periodic heartbeats to Uptime Kuma's Push monitor

set -e

# Configuration from environment variables
PUSH_URL="${PUSH_URL:-}"
PUSH_INTERVAL="${PUSH_INTERVAL:-60}"
PUSH_MSG="${PUSH_MSG:-OK}"
PUSH_PING="${PUSH_PING:-}"

# Validate required variables
if [ -z "$PUSH_URL" ]; then
    echo "ERROR: PUSH_URL environment variable is required"
    echo "Example: https://uptime.example.com/api/push/abc123"
    exit 1
fi

# Build the URL with optional parameters
build_url() {
    url="$PUSH_URL"
    params=""
    
    if [ -n "$PUSH_MSG" ]; then
        # URL encode the message (basic)
        encoded_msg=$(echo "$PUSH_MSG" | sed 's/ /%20/g')
        params="msg=${encoded_msg}"
    fi
    
    if [ -n "$PUSH_PING" ]; then
        if [ -n "$params" ]; then
            params="${params}&ping=${PUSH_PING}"
        else
            params="ping=${PUSH_PING}"
        fi
    fi
    
    if [ -n "$params" ]; then
        # Check if URL already has query params
        case "$url" in
            *\?*) echo "${url}&${params}" ;;
            *)    echo "${url}?${params}" ;;
        esac
    else
        echo "$url"
    fi
}

FULL_URL=$(build_url)

echo "========================================"
echo "Uptime Kuma Push Agent"
echo "========================================"
echo "Push URL: $PUSH_URL"
echo "Interval: ${PUSH_INTERVAL}s"
echo "Message:  $PUSH_MSG"
[ -n "$PUSH_PING" ] && echo "Ping:     ${PUSH_PING}ms"
echo "========================================"
echo ""

# Main loop
while true; do
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if response=$(curl -fsS -m 10 "$FULL_URL" 2>&1); then
        echo "[$timestamp] ✓ Heartbeat sent successfully"
    else
        echo "[$timestamp] ✗ Failed to send heartbeat: $response"
    fi
    
    sleep "$PUSH_INTERVAL"
done
