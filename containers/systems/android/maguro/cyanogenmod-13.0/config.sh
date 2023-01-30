#!/bin/bash

#
# Source
#
rom_local="cm-13.0-20161219-NIGHTLY-maguro.zip"
#rom_url="https://cyanogenmodroms.com/link/cm-13-0-20161219-nightly-maguro-zip"
rom_url="https://github.com/matthiasbock/android-images/releases/download/maguro-cm13/cm-13.0-20161219-NIGHTLY-maguro.zip"
rom_md5sum="00c135c65217357f97eb8d489de0fe20"
rom_sha256sum="8014524ee401f4ff36d4d0cc74e49149d01c47ced5ea137c01cf32e25a05c374"

#
# Container/image configuration
#
image_name="android"
codename="maguro"
release="cm13"
image_tag="${codename}-${release}"

container_name="${image_name}_${image_tag}"
container_architecture="linux/arm32v7"

image_config="USER=root WORKDIR=/ CMD=['/qemu-arm-static','/system/bin/sh']"
image_repositories="docker.io/matthiasbock/$image_name:$image_tag registry.bihealth.org:443/bockm/recipes/$image_name:$image_tag"


#
# Tools
#
sdat2img="$shared_dir/sdat2img/sdat2img.py"
chmod +x $sdat2img
#verify_md5sum 1bbe2e2a5aa7d9fd5c55e60331f705f4 "$sdat2img"

required_tools="cp mv rm rmdir rsync sudo mount umount wget md5sum sha256sum unzip abootimg $sdat2img"
for tool in $required_tools; do
  if [ ! -e "$tool" ] && [ ! -e "$(which $tool)" ]; then
    echo "Error: Could not find required tool $tool. Aborting."
    exit 1
  fi
done
