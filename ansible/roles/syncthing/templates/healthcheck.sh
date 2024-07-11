#!/bin/sh
#
# Checks, whether syncthing is up and running
# by verifying that the nominal TCP and UDP ports are listened on
#
# To update a Prometheus file, the environment must define:
# * CONTAINER_NAME
# * PROMETHEUS_FILE
# * PROMETHEUS_METRIC
#

# Ports to check for connectivity
TCP_PORTS="8384 22000"
UDP_PORTS="22000 21027"

# Function to check TCP port connectivity
check_tcp_port() {
  local port=$1
  nc -vzw 3 localhost $port 2>&1
  return $?
}

# Function to check UDP port connectivity
check_udp_port() {
  local port=$1
  echo -n "" | nc -vuzw 3 localhost $port 2>&1
  return $?
}

# Function to set health status
set_health_status() {
  local STATUS="$1"
  local ERROR_MESSAGE="$2"

  if [ "$CONTAINER_NAME" = "" ]; then return; fi
  if [ "$PROMETHEUS_FILE" = "" ]; then return; fi
  if [ ! -f "$PROMETHEUS_FILE" ]; then exit 2; fi
  if [ "$PROMETHEUS_METRIC" = "" ]; then return; fi

  local PAYLOAD="container=\"$CONTAINER_NAME\",timestamp=\"$(date)\""

  if [ "$ERROR_MESSAGE" != "" ]; then PAYLOAD="$PAYLOAD,error=\"$ERROR_MESSAGE\""; fi

  echo "${PROMETHEUS_METRIC}{$PAYLOAD} $STATUS" > $PROMETHEUS_FILE
}

error() {
  local ERROR="$1"
  echo $ERROR
  set_health_status 0 "$ERROR"
  exit 1
}

# Check the health status of the web UI
echo "Testing web interface..."
if ! curl -fs http://localhost:8384 >/dev/null; then
  error "Web UI is not accessible"
fi

REST_STATUS=$(curl -fkLsS -m 2 localhost:8384/rest/noauth/health)
if [ ! $? ]; then
  error "Failed to query Syncthing's REST interface"
fi

echo $REST_STATUS | fgrep -o --color=never OK
if [ ! $? ]; then
  error "Syncthing status is not OK"
fi

# Check connectivity for each TCP port
for port in $TCP_PORTS; do
  echo "Testing TCP port: $port"
  if ! check_tcp_port $port; then
    error "TCP port $port is not accessible"
  fi
done

# Check connectivity for each UDP port
for port in $UDP_PORTS; do
  echo "Testing UDP port: $port"
  if ! check_udp_port $port; then
    error "UDP port $port is not accessible"
  fi
done

# If all checks pass
echo "Container seems healthy"
set_health_status 1
exit 0

