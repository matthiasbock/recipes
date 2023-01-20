#!/bin/bash

set -e

# Change to the folder containing this script
export initial_pwd="$(pwd)"
export scriptpath="$(pwd)"
argc=${#BASH_SOURCE[@]}
for argv in ${BASH_SOURCE}; do
  if [[ "$argv" == *"publish-dockerhub.sh"* ]]; then
    scriptpath="$argv"
    break
  fi
done
test -f "${scriptpath}" \
 || { echo "Error: Script not found: $scriptpath. Aborting."; exit 1; }
cd $(dirname $(realpath "$scriptpath")) \
 || { echo "Error: Failed to change to working directory. Aborting."; exit 1; }

# Prepare for script execution
export container_config="$1"
source "setup.sh" \
 || { echo "Error: Failed to load setup script. Aborting."; exit 1; }


if ! image_exists "${image_name}:${image_tag}"; then
  echo "Fatal: Image '${image_name}:${image_tag}' not found."
  exit 1
fi

# TODO: Check: Are Docker Hub credentials defined?

$container_cli login -u $DOCKER_HUB_USERNAME -p $DOCKER_HUB_ACCESS_TOKEN docker.io

$container_cli push "${image_name}:${image_tag}" "${dockerhub_repository}"
