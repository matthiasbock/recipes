#!/bin/bash

#
# Source
#
export rom_local="cm-13.0-20161219-NIGHTLY-maguro.zip"
#export rom_url="https://cyanogenmodroms.com/link/cm-13-0-20161219-nightly-maguro-zip"
export rom_url="https://github.com/matthiasbock/android-images/releases/download/maguro-cm13/cm-13.0-20161219-NIGHTLY-maguro.zip"
export rom_md5sum="00c135c65217357f97eb8d489de0fe20"
export rom_sha256sum="8014524ee401f4ff36d4d0cc74e49149d01c47ced5ea137c01cf32e25a05c374"

#
# Settings
#
export image_name="android"
export codename="maguro"
export release="cm13"
export image_tag="${codename}-${release}"
export container_name="${image_name}-${image_tag}"
export image_config="USER=root WORKDIR=/ CMD=['/qemu-arm-static','/system/bin/sh']"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"

#
# Tools
#
export sdat2img="$common/sdat2img/sdat2img.py"
chmod +x $sdat2img
#verify_md5sum 1bbe2e2a5aa7d9fd5c55e60331f705f4 "$sdat2img"

export required_tools="cp mv rm rmdir rsync sudo mount umount wget md5sum sha256sum unzip abootimg $sdat2img"
for tool in $required_tools; do
  if [ ! -e "$tool" ] && [ ! -e "$(which $tool)" ]; then
    echo "Error: Could not find required tool $tool. Aborting."
    exit 1
  fi
done
