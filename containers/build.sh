#!/bin/bash
#
# This script builds a container according to the
# parameters specified in the given file.
#

echo  "---------------------------- recipes/containers/build.sh ----------------------------"

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
 || { echo "Error: Failed to load setup script. Aborting."; exit 4; }


#
# Build container from Dockerfile
#
if [ "$dockerfile" != "" ]; then
  echo "Building image using Dockerfile: \"$dockerfile\"..."
  dockerfile_dir="$(dirname "$dockerfile")"
  cd "$dockerfile_dir" && $container_cli build -t $image_name:$image_tag . \
  || { echo "Error: Failed to build image using Dockerfile."; echo 5; }

  # We don't need to build another container
  skip_container_creation=true
  skip_container_start=true
fi

#
# Create the container
#
if ! $skip_container_creation; then
  if container_exists "$container_name"; then
  	echo "Warning: A container named \"$container_name\" exists and will be deleted. Press Ctrl-C within 5s to abort..."
    sleep 5
  	container_remove "$container_name" \
     || { echo "Error: Failed to remove existing container \"$container_name\"."; exit 6; }
  fi
  container_create "$container_name" "$base_image" "$container_architecture" "$container_constructor" \
   || { echo "Error: Failed to create container \"$container_name\"."; exit 7; }
fi

#
# Work on the newly created container
#
if ! $skip_container_start; then
  echo -n "Starting container... "
  container_start "$container_name" \
   || { echo "Error: Failed to start container \"$container_name\"."; exit 8; }
  echo "ok."
fi

# Run setup function from configuration script
echo "Begin container configuration... "
if [ "$(type -t container_setup)" != "function" ]; then
  # If no setup function is defined, use the default one from the library
  . "$lib_container/src/setup.sh"
fi
container_setup \
 || { echo "Error: Container configuration failed (exit code $?)."; exit 9; }
echo "Container configuration complete."

# Container created successfully
echo -n "Stopping... "
container_stop "$container_name" \
 || { echo "Error: Failed to stop container."; exit 10; }
echo "ok."
#container_size=$(container_get_size $container_name)
#echo "Container size is $container_size."
echo "Container $container_name created successfully."

echo "Availabe containers are now:"
$container_cli container ls -a

# Return to original directory
cd "$initial_dir"
