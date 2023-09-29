#!/bin/bash

# TODO: Enable running from paths other than the one containing this script.
shared_dir=$(realpath "../../../../../shared")

# Load container configuration
. config.sh

# Include container management routines for bash
lib_container="$shared_dir/bash-container-library"
. "$lib_container/include.sh" \
 || { echo "Error: Failed to load bash container library."; exit 1; }

# Commit folder as image
dir="image"
image_create_from_folder $dir "matthiasbock/$image_name:$image_tag"
