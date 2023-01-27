#!/bin/bash

set -e

# Change to the folder containing this script
initial_pwd="$(pwd)"
scriptpath="$(realpath "$0")"

# Verify script path
test -f "$scriptpath" \
 || { echo "Error: Script not found: $scriptpath. Aborting."; exit 1; }

# Change to the folder containing this script
cd $(dirname "$scriptpath") \
 || { echo "Error: Failed to change to working directory. Aborting."; exit 1; }

# Prepare for script execution
container_config="$1"
. "setup.sh" \
 || { echo "Error: Failed to load setup script. Aborting."; exit 1; }


container_remove "$container_name"
