
export image_name="buildenv-openssh"
export release="buster"
export architecture="amd64"
export image_tag="${release}-${architecture}"
export base_image="docker.io/matthiasbock/debian-base:${image_tag}"
export container_name="${image_name}-${image_tag}"

export user="runner"
export hostname="${image_name}"

export image_config="USER=${user} WORKDIR=/home/${user} CMD=/bin/bash"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"


function container_setup()
{
  # Set hostname
  container_set_hostname $container_name "$hostname" \
   || { echo "Failed to set hostname. Aborting."; exit 1; }

  # run.sh
  container_add_file $container_name $(dirname $(realpath "${container_config}"))/run.sh /home/${user}/ \
   || { echo "Failed to add compilation script. Aborting."; exit 1; }
  container_exec $container_name chmod 755 /home/${user}/run.sh \
   || { echo "Failed to change file mode. Aborting."; exit 1; }
  container_exec $container_name chown -R $user:$user /home/${user} \
   || { echo "Failed to change file ownership. Aborting."; exit 1; }

  # apt build-dep
  container_debian_install_packages git ccache \
   || { echo "Failed to install additional packages. Aborting."; exit 1; }
  container_debian_install_build_dependencies $container_name openssh-{server,client,sftp-server,tests} \
   || { echo "Failed to install build dependencies. Aborting."; exit 1; }

  # Clean up
  container_expendables_import "$lib_container/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
