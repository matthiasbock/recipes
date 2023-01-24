#!/bin/bash
#
# This script builds a container according to the
# parameters specified in the given file.
#

set -e

# Remember where execution started
export initial_pwd="$(realpath .)"

# Determine the full path to this script
export scriptpath="$(realpath .)"
argc=${#BASH_SOURCE[@]}
for argv in ${BASH_SOURCE}; do
  if [[ "$argv" == *"build.sh"* ]]; then
    scriptpath="$(realpath $argv)"
    break
  fi
done
# Verify script path
test -f "${scriptpath}" \
 || { echo "Error: Script not found: \"${scriptpath}\". Aborting."; exit 1; }

 # Change to the folder containing this script
cd $(dirname "${scriptpath}") \
 || { echo "Error: Failed to change to working directory. Aborting."; exit 1; }

#
# A container configuration may skip container creation or startup.
# Default: don't skip anything
#
export skip_container_creation=false
export skip_container_start=false

# Prepare for script execution
export container_config="$1"
source "setup.sh" \
 || { echo "Error: Failed to load setup script. Aborting."; exit 1; }

#
# Create the container
#
if $skip_container_creation; then
  echo "Skipping container creation as requested."
else
  if container_exists "$container_name"; then
  	echo "Warning: Container \"$container_name\" already exists. Aborting."
  	exit 0
  fi
  create_container "$container_name" $container_constructor \
   || { echo "Error: Failed to create container. Aborting. "; exit 1; }
fi

#
# Work on the newly created container
#
if $skip_container_start; then
  echo "Skipping container start as requested."
else
  echo "Starting container ..."
  container_start "$container_name" \
   || { echo "Error: Unable to start newly created container. Aborting."; exit 1; }
fi

# Run setup function from configuration script
container_setup

# Done
$container_cli stop "$container_name"
echo "Container $container_name created successfully."
#container_size=$(container_get_size $container_name)
#echo "Container size is $container_size."
