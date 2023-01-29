#!/bin/bash
#
# Commit an existing container as image
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

# Include shared setup routines as well as container config script
. "setup.sh" \
 || { echo "Error: Failed to include setup script."; exit 4; }


# Run a pre-commit hook, if one is defined
if [ "$(type -t pre_commit_hook)" == "function" ]; then
  echo "Running pre-commit hook..."
  pre_commit_hook \
   || { echo "Error: Pre-commit hook failed."; exit 1; }
fi

# Commit container as image
echo "Committing container to image..."
create_image_from_container $container_name $image_name $image_tag "$image_config" \
 || { echo "Error: Image creation failed."; exit 5; }
echo "Image creation complete."


# Return to original directory
cd "$initial_dir"
