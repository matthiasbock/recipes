#!/bin/bash

# Check Netbox web server
if ! curl -f http://localhost:8080/login/ > /dev/null 2>&1; then
  exit 1
fi

# Check rqworker
if ! ps -aux | grep -v grep | grep -q rqworker; then
  exit 1
fi

# Check housekeeping (if applicable)
if ! ps -aux | grep -v grep | grep -q housekeeping; then
  exit 1
fi

# Check PostgreSQL (adjust connection details as needed)
if ! pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" -h localhost -p 5432; then
  exit 1
fi

# Check Redis instances (adjust passwords as needed)
if ! redis-cli -a "$REDIS_PASSWORD" -h localhost -p 6379 ping | grep PONG; then
  exit 1
fi

if ! redis-cli -a "$REDIS_CACHE_PASSWORD" -h localhost -p 6380 ping | grep PONG; then
  exit 1
fi

exit 0

