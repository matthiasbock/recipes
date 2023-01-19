
export image_name="buildenv-generic"

# Debian release and target architecture are defined in separate files.
export image_tag="${release}-${architecture}"
export base_image="docker.io/matthiasbock/debian-base:${image_tag}"
export container_name="${image_name}_${image_tag}"

export user="runner"
export hostname="${image_name}"

export image_config="USER=${user} WORKDIR=/home/${user} ENTRYPOINT=/bin/bash"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"


function container_setup()
{
  # Install additional packages
  container_debian_install_package_bundles \
    keyrings debian-essentials console-tools version-control build-tools \
   || { echo "Failed to install packages. Aborting."; exit 1; }

  # Clean up
  container_expendables_import "${bash_container_library}/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
