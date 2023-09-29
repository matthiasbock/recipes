
export image_name="buildenv-android"
export release="buster"
export architecture="amd64"
export image_tag="${release}-${architecture}"
export base_image="docker.io/matthiasbock/debian-base:${image_tag}"
export container_name="${image_name}-${image_tag}"

export user="runner"
export hostname="${image_name}"

export image_config="USER=${user} WORKDIR=/home/${user} CMD=/bin/bash"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"


function container_setup_failed()
{
  echo "Rolling back..."
  container_stop $container_name
  container_remove $container_name
}


function container_setup()
{
  # Install/Uninstall packages
  container_exec $container_name apt-get -q update \
    || { echo "Failed to update package list. Aborting."; container_setup_failed; exit 1; }
#  container_exec $container_name apt-get upgrade -y \
#    || { echo "Failed to upgrade packages. Aborting."; container_setup_failed; exit 1; }
  container_exec $container_name apt-get -q remove -y $(cat "$container_config_dir/uninstall.list" | sed -ze "s/\n/ /g") \
    || { echo "Failed to remove packages. Aborting."; container_setup_failed; exit 1; }
  container_exec $container_name apt-get -q install -y $(cat "$container_config_dir/install.list" | sed -ze "s/\n/ /g") \
    || { echo "Failed to install packages. Aborting."; container_setup_failed; exit 1; }

 #container_exec $container_name apt-mark hold $(cat "$container_config_dir/mark-hold.list" | sed -ze "s/\n/ /g") \
 #   || { echo "Failed to mark unneeded packages. Aborting."; container_setup_failed; exit 1; }

  # Configure git
  container_exec $container_name sudo -u $user git config --global user.name "$user" \
   || { echo "Failed to configure git. Aborting."; container_setup_failed; exit 1; }
  container_exec $container_name sudo -u $user git config --global user.email "$user@$image_name" \
   || { echo "Failed to configure git. Aborting."; container_setup_failed; exit 1; }

  # Clean up
  container_expendables_import "$lib_container/expendables/default.list" \
   || { echo "Failed to load list of expendable files and folders. Aborting."; container_setup_failed; exit 1; }
  container_expendables_delete $container_name \
   || { echo "Failed to tidy-up container. Aborting."; container_setup_failed; exit 1; }
}
