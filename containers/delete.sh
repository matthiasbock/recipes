#!/bin/bash
#
# Delete the container specified in the given container configuration file
#

echo  "---------------------------- recipes/containers/delete.sh ----------------------------"

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

# Include shared setup routines as well as container config script
. "setup.sh" \
 || { echo "Error: Failed to include setup script."; exit 1; }


if container_exists "$container_name"; then
  # Delete the container
  echo "Deleting container \"$container_name\"..."
  container_remove "$container_name"
else
  echo "No such container: \"$container_name\""
  # exit 1;
fi


# Return to original directory
cd "$initial_dir"
