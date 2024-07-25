#!/bin/bash
#
# Checks for the presence of a firewall and
# attempts to start one if none is configured
#

# Configuration
INTERFACES="{{ INTERFACES }}"
SERVICE_NAME="{{ SERVICE_NAME }}"

# Bring down the network interface and log an error
failsafe_stop_networking() {
    logger -t $SERVICE_NAME "Invoking failsafe: Stopping networking to prevent intrusion"
    systemctl stop networking NetworkManager ModemManager
    sleep 3
    ip link set "$INTERFACES" down
    ip link set lo up
}

# Function to check if nftables has any active rules
if_nftables_configured() {
    RULE_COUNT=$(env nft list ruleset | wc -l)
    if [ $? -ne 0 ]; then
        logger -t $SERVICE_NAME "Failed to probe netfilter ruleset"
        return false
    fi
    if [ "$RULE_COUNT" -le 1 ]; then
        logger -t $SERVICE_NAME "Firewall is not configured"
        return false
    else
        # logger -t $SERVICE_NAME "Firewall is configured"
        return true
    fi
}

# Function to check if firewall-cmd is installed
is_firewalld_installed() {
    if command -v firewall-cmd &> /dev/null; then
        return true
    else
        return false
    fi
}

# Function to check if firewalld is running
is_firewalld_running() {
if systemctl is-active --quiet firewalld; then
    return true
else
    return false
fi
}

if is_nftables_configured; then
    # Everything is fine
    exit
fi

#
# Try to start firewalld
#
if is_firewalld_installed; then
    if is_firewalld_running; then
        # This is fine...
        # logger -t $SERVICE_NAME "firewalld is installed and running"
        exit
    fi
    logger -t $SERVICE_NAME "Starting firewalld service"
    systemctl start firewalld
    if [ $? -ne 0 ]; then
        logger -t $SERVICE_NAME "Error trying to start firewalld service"
        failsafe_stop_networking
        exit
    fi
    sleep 10
    if is_firewalld_running; then
        # Problem solved
        exit
    else
        logger -t $SERVICE_NAME "Failed to start firewalld service"
        failsafe_stop_networking
        exit
    fi
fi

#
# Try to apply static nftables rules
#
if [ -f {{ NFTABLES_CONF_PATH }} ]; then
    logger -t $SERVICE_NAME "Applying nftables rules from: {{ NFTABLES_CONF_PATH }}"
    nft -f {{ NFTABLES_CONF_PATH }}
    if [ $? -ne 0 ]; then
        logger -t $SERVICE_NAME "Error trying to apply nftables rules from: {{ NFTABLES_CONF_PATH }}"
        failsafe_stop_networking
        exit
    fi
    if ! is_nftables_configured; then
        logger -t $SERVICE_NAME "Configuration error: nftables should have been configured at this point"
        failsafe_stop_networking
        exit
    fi
fi

if ! is_nftables_configured; then
    logger -t $SERVICE_NAME "ALERT: Firewall is left unconfigured"
    failsafe_stop_networking
    exit
fi

exit 0
