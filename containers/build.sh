#!/bin/bash
#
# This script builds a container according to the
# parameters specified in the given file.
#

# Path to container configuration/setup script
container_config="$1"

# Change to the folder containing this script
initial_dir="$(realpath "$(pwd)")"
script_filename="$(realpath "$0")"
script_dir="$(dirname "$script_filename")"

# Verify script path
[[ -f "$script_filename" ]] \
 || { echo "Error: Script not found: \"$script_filename\""; exit 2; }

# Change to the folder containing this script
cd "$script_dir" \
 || { echo "Error: Failed to change to working directory \"$script_dir\"."; exit 3; }

#
# A container configuration may skip container creation or startup.
# Default: don't skip anything
#
skip_container_creation=false
skip_container_start=false

# Include shared setup routines as well as container config script
. "setup.sh" \
 || { echo "Error: Failed to load setup script. Aborting."; exit 1; }


#
# Create the container
#
if ! $skip_container_creation; then
  if container_exists "$container_name"; then
  	echo "Warning: A container named \"$container_name\" exists and will be deleted. Press Ctrl-C within 5s to abort..."
    sleep 5
  	container_remove "$container_name" \
     || { echo "Error: Failed to remove existing container \"$container_name\"."; exit 1; }
  fi
  create_container "$container_name" $container_constructor \
   || { echo "Error: Failed to create container \"$container_name\"."; exit 1; }
fi

#
# Work on the newly created container
#
if ! $skip_container_start; then
  echo "Starting container ..."
  container_start "$container_name" \
   || { echo "Error: Failed to start container \"$container_name\"."; exit 1; }
fi

# Run setup function from configuration script
container_setup

# Container created successfully
$container_cli stop "$container_name" \
 || { echo "Error: Failed to stop container."; exit 1; }
#container_size=$(container_get_size $container_name)
#echo "Container size is $container_size."
echo "Container $container_name created successfully."


# Return to original directory
cd "$initial_dir"
