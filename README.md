# Uptime Kuma Push Agent

A minimal Docker container that sends periodic heartbeats to [Uptime Kuma](https://github.com/louislam/uptime-kuma)'s Push monitor.

**Perfect for monitoring devices that can't be reached from the internet** (like a Raspberry Pi behind NAT) - the device pushes its status to Uptime Kuma instead of Uptime Kuma polling the device.

## Features

- 🪶 **Minimal** - Alpine-based, ~8MB image size
- 🏗️ **Multi-arch** - Works on amd64, arm64, armv7 (Raspberry Pi)
- ⚙️ **Configurable** - Interval, message, and ping values via environment variables
- 🔒 **Secure** - Runs as non-root user

## Quick Start

### 1. Create a Push Monitor in Uptime Kuma

1. In Uptime Kuma, click **"Add New Monitor"**
2. Select **"Push"** as the Monitor Type
3. Set your desired **Heartbeat Interval** (e.g., 60 seconds)
4. Click **Save** and copy the **Push URL**

### 2. Run the Container

**Using Docker Run:**

```bash
docker run -d \
  --name uptime-kuma-push \
  --restart unless-stopped \
  -e PUSH_URL="https://uptime.example.com/api/push/abc123xyz" \
  -e PUSH_INTERVAL=60 \
  ghcr.io/akhilrex/uptime-kuma-push-agent:latest
```

**Using Docker Compose:**

```yaml
services:
  uptime-kuma-push:
    image: ghcr.io/akhilrex/uptime-kuma-push-agent:latest
    container_name: uptime-kuma-push
    restart: unless-stopped
    environment:
      - PUSH_URL=https://uptime.example.com/api/push/abc123xyz
      - PUSH_INTERVAL=60
```

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `PUSH_URL` | ✅ Yes | - | The Push URL from Uptime Kuma |
| `PUSH_INTERVAL` | No | `60` | Seconds between heartbeats |
| `PUSH_MSG` | No | `OK` | Status message to send |
| `PUSH_PING` | No | - | Ping/latency value in ms to report |

## Building Locally

```bash
# Clone the repo
git clone https://github.com/akhilrex/uptime-kuma-push-agent.git
cd uptime-kuma-push-agent

# Build for current architecture
docker build -t uptime-kuma-push-agent .

# Build for multiple architectures (for Raspberry Pi support)
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t ghcr.io/akhilrex/uptime-kuma-push-agent:latest \
  --push .
```

## How It Works

```
┌─────────────────┐                    ┌─────────────────┐
│  Raspberry Pi   │                    │  Uptime Kuma    │
│  (behind NAT)   │                    │  (on internet)  │
│                 │                    │                 │
│  ┌───────────┐  │   HTTP GET every   │  ┌───────────┐  │
│  │ Push Agent│──┼───── 60 seconds ──▶│  │Push Monitor│  │
│  └───────────┘  │                    │  └───────────┘  │
│                 │                    │        │        │
└─────────────────┘                    │        ▼        │
                                       │  If no heartbeat │
                                       │  received, send  │
                                       │  notification!   │
                                       └─────────────────┘
```

## Tips

- Set `PUSH_INTERVAL` slightly lower than Uptime Kuma's Heartbeat Interval to account for network delays
- Example: If Uptime Kuma expects a heartbeat every 60s, set `PUSH_INTERVAL=50`

## License

MIT
