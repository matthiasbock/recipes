#!/bin/bash

# TODO: Enable running from paths other than the one containing this script.
shared_dir=$(realpath "../../../../../shared")

# Load container configuration
. config.sh

# Include container management routines for bash
bash_container_library="$shared_dir/bash-container-library"
. "$bash_container_library/include.sh" \
 || { echo "Error: Failed to load bash container library."; exit 1; }

# Commit folder as image
dir="image"
image_create_from_folder $dir "matthiasbock/$image_name:$image_tag"
