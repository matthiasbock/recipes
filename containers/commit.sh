#!/bin/bash

set -e

# Change to the folder containing this script
initial_pwd="$(pwd)"
scriptpath="$(realpath "$0")"

# Verify script path
test -f "${scriptpath}" \
 || { echo "Error: Script not found: $scriptpath. Aborting."; exit 1; }

# Change to the folder containing this script
cd $(dirname $(realpath "$scriptpath")) \
 || { echo "Error: Failed to change to working directory. Aborting."; exit 1; }

# Prepare for script execution
container_config="$1"
. "setup.sh" \
 || { echo "Error: Failed to load setup script. Aborting."; exit 1; }

# Run a pre-commit hook, if one is defined
if [ "$(type -t pre_commit_hook)" == "function" ]; then
  pre_commit_hook
fi

# Commit container as image
echo "Committing..."
create_image_from_container $container_name $image_name $image_tag "$image_config" \
 || { echo "Error: Image creation failed. Aborting."; exit 1; }
echo "Image creation complete."
