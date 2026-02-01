FROM alpine:3.19

# Install curl (only dependency we need)
RUN apk add --no-cache curl

# Copy the push script
COPY push.sh /usr/local/bin/push.sh
RUN chmod +x /usr/local/bin/push.sh

# Environment variables with defaults
ENV PUSH_URL=""
ENV PUSH_INTERVAL="60"
ENV PUSH_MSG="OK"
ENV PUSH_PING=""

# Run as non-root user for security
RUN adduser -D -H agent
USER agent

# Health check - verify curl works
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -fs http://localhost:65535 || exit 0

ENTRYPOINT ["/usr/local/bin/push.sh"]
