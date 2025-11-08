#!/bin/bash
#
# Fetches all SSH host keys from the specified host and
# updates the ansible inventory accordingly.
#
# Usage: fetch-ssh-host-keys.sh [remote hostname] [remote user] [path to ansible.cfg] [path to ssh.yml]
#

# Default values
HOST=""
USER="root"
ANSIBLE_CFG="/etc/ansible/ansible.cfg"
ANSIBLE_INVENTORY_SSH_YAML="/etc/ansible/inventory/group_vars/ssh.yml"

# Parse command line arguments
while getopts ":h:u:c:i:-:" OPT; do
    case "${OPT}" in
        h) HOST="$OPTARG";;
        u) USER="$OPTARG";;
        c) ANSIBLE_CFG="$OPTARG";;
        i) ANSIBLE_INVENTORY_SSH_YAML="$OPTARG";;
        -)
            case "${OPTARG}" in
                host=*) HOST="${OPTARG#*=}";;
                user=*) USER="${OPTARG#*=}";;
                config=*) ANSIBLE_CFG="${OPTARG#*=}";;
                inventory=*) ANSIBLE_INVENTORY_SSH_YAML="${OPTARG#*=}";;
                *) echo "Invalid option: --${OPTARG}" >&2; exit 1;;
            esac;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
        :) echo "Option -$OPTARG requires an argument" >&2; exit 1;;
    esac
done

if [ -z "$HOST" ]; then
    echo "Usage: $0 --host=<host> | -h <host> [--user=<user> | -u <user>] [--config=<ansible.cfg> | -c <ansible.cfg>] [--inventory=<ssh.yml> | -i <ssh.yml>]" >&2
    exit 1
fi

if [ ! -f "$ANSIBLE_INVENTORY_SSH_YAML" ]; then
    echo "File not found: $ANSIBLE_INVENTORY_SSH_YAML" >&2

    # Parse path to ansible inventory from ansible.cfg
    echo "Attempting to parse path to ansible inventory from ansible.cfg: $ANSIBLE_CFG ..." >&2
    ANSIBLE_INVENTORY_DIR=$(grep -E '^inventory\s*=' "$ANSIBLE_CFG" | cut -d= -f2 | tr -d ' ')
    if [ -z "$ANSIBLE_INVENTORY_DIR" ] || [ ! -d "$ANSIBLE_INVENTORY_DIR" ]; then
        echo "Found neither ssh.yml: $ANSIBLE_INVENTORY_SSH_YAML, nor inventory directory: $ANSIBLE_INVENTORY_DIR" >&2
        exit 1
    fi
    echo "Found inventory at: $ANSIBLE_INVENTORY_DIR" >&2

    ANSIBLE_INVENTORY_SSH_YAML="$ANSIBLE_INVENTORY_DIR/group_vars/ssh.yml"
    if [ ! -f "$ANSIBLE_INVENTORY_SSH_YAML" ]; then
        echo "File not found: $ANSIBLE_INVENTORY_SSH_YAML" >&2
        exit 1
    fi
    echo "Found ssh.yml at: $ANSIBLE_INVENTORY_SSH_YAML" >&2
fi

function update_host_key {
    local HOST=$1
    local KEY_TYPE=$2
    local KEY=$3

    local TMPFILE=$(mktemp)
    yq ".ssh_host_keys.$HOST.$KEY_TYPE = $KEY" $ANSIBLE_INVENTORY_SSH_YAML > $TMPFILE
    mv -vn $TMPFILE $ANSIBLE_INVENTORY_SSH_YAML
}

function remove_host_key {
    local HOST=$1
    local KEY_TYPE=$2
    local TMPFILE=$(mktemp)

    if [ "$HOST" == "" ]; then
        echo "Usage: $0 <host> <key_type>" >&2
        return 1
    fi
    if [ ! "$KEY_TYPE" =~ rsa|ecdsa|ed25519 ]; then
        echo "Unsupported key type: $KEY_TYPE. Acceptable types: rsa, ecdsa, ed25519" >&2
        return 1
    fi

    echo "Removing $KEY_TYPE host key for $HOST from $ANSIBLE_INVENTORY_SSH_YAML ..." >&2
    yq ".ssh_host_keys.$HOST.$KEY_TYPE = null" $ANSIBLE_INVENTORY_SSH_YAML > $TMPFILE
    mv -vn $TMPFILE $ANSIBLE_INVENTORY_SSH_YAML
}

echo "Fetching SSH host keys from: $HOST ..." >&2
# KEYS=$(ssh $USER@$HOST cat /etc/ssh/ssh_host_*.pub)
KEYS=$(ssh-keyscan $HOST)
RSA_KEY=$(echo $KEYS | fgrep ssh-rsa | cut -d" " -f2)
ECDSA_KEY=$(echo $KEYS | fgrep ecdsa-sha2-nistp256 | cut -d" " -f2)
ED25519_KEY=$(echo $KEYS | fgrep ssh-ed25519 | cut -d" " -f2)

if [ -n "$RSA_KEY" ]; then
    echo "RSA public key: $RSA_KEY"
    update_host_key $HOST rsa $RSA_KEY
else
    echo "No RSA key found" >&2
    remove_host_key $HOST rsa
fi

if [ -n "$ECDSA_KEY" ]; then
    echo "ECDSA public key: $ECDSA_KEY"
    update_host_key $HOST ecdsa $ECDSA_KEY
else
    echo "No ECDSA key found" >&2
    remove_host_key $HOST ecdsa
fi

if [ -n "$ED25519_KEY" ]; then
    echo "ED25519 public key: $ED25519_KEY"
    update_host_key $HOST ed25519 $ED25519_KEY
else
    echo "No ED25519 key found" >&2
    remove_host_key $HOST ed25519
fi
