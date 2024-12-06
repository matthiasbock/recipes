#!/bin/bash

# Start Redis servers (adjust paths and passwords as needed)
redis-server --appendonly yes --requirepass "$REDIS_PASSWORD" --dir /data/redis &
redis-server --requirepass "$REDIS_CACHE_PASSWORD" --dir /data/redis-cache &

# Start supervisord
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
