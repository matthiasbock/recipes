#!/bin/bash

# TODO: Enable running from paths other than the one containing this script.
shared_dir=$(realpath "../../../../../shared")

# Load container configuration
. config.sh

# Build image
mkimage
