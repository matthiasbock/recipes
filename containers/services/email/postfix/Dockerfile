
# Derive from the latest mailcow postfix image
FROM docker.io/mailcow/postfix:latest

# Add an entrypoint script
ADD ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Add netcat (for the healt hcheck)
# RUN \
# apt-get update && \
# apt-get install -y netcat && \
# rm -rf /var/cache/apt/* /var/lib/apt/lists/*

# HEALTHCHECK \
# --interval=60s \
# --timeout=3s \
# --start-period=5s \
# --retries=3 \
# CMD nc -z -w 1 localhost 25
