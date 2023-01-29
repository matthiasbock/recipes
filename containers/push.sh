#!/bin/bash
#
# Push a local container image
# to one container registry
# specified via environment variables
#

# Path to container configuration/setup script
container_config="$(realpath "$1")"

# Change to the folder containing this script
initial_dir="$(realpath "$(pwd)")"
script_filename="$(realpath "$0")"
script_dir="$(dirname "$script_filename")"

# Verify script path
[[ -f "$script_filename" ]] \
 || { echo "Error: Script not found: $script_filename."; exit 2; }

# Change to the folder containing this script
cd "$script_dir" \
 || { echo "Error: Failed to change to working directory."; exit 3; }

# Include shared setup routines as well as container config script
. "setup.sh" \
 || { echo "Error: Failed to load setup script. Aborting."; exit 4; }


# Check if the image exists
image_id="$image_name:$image_tag"
if ! image_exists "$image_id"; then
  echo "Error: Image not found: \"$image_id\""
  exit 5
fi

# Push this image under all configured tags
image_tags="$image_tag $image_tags"
echo "Image tags: $image_tags"
echo "Image repositories: $image_repositories"
for tag in $image_tags; do
  # Push image to all configured repositories
  for repository in $image_repositories; do
    echo "Pushing image \"$image_id\" to \"$repository:$tag\"..."
    $container_cli push "$image_id" "$repository:$tag"
  done
done
echo "Pushing complete."


# Return to original directory
cd "$initial_dir"
