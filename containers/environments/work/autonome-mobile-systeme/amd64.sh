
export image_name="autonome-mobile-systeme"
export release="ubuntu"
export architecture="amd64"
export base_image="docker.io/matthiasbock/ubuntu-base:focal-${architecture}"
export image_tag="latest"
export container_name="${image_name}-${image_tag}"

source $project_root/containers/user.sh

# Commit the result as image
export image_config="USER=${user} WORKDIR=/home/${user} CMD=/bin/bash"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"


function container_setup()
{
  # Install build dependencies
  container_exec $container_name apt-get -q update
  container_exec $container_name apt-get -q install --no-install-recommends --no-install-suggests -y $(cat "${container_config_dir}/build.list" "${container_config_dir}/runtime.list")

  # Build player
  container_exec $container_name sudo -u $user git clone https://github.com/playerproject/player.git /home/$user/player
  container_exec $container_name sudo -u $user bash -c "cd /home/$user/player && git checkout f0109df && mkdir build && cd build && cmake ../ -Wno-dev && make -j4 && make && sudo make install && make clean && sudo ldconfig" \
   || { echo "Error: Failed to compile Player. Aborting."; exit 1; }

  # Build stage
  container_exec $container_name sudo -u $user git clone http://github.com/rtv/Stage.git /home/$user/stage
  container_exec $container_name sudo -u $user bash -c "cd /home/$user/stage; git checkout 0c85412 && mkdir build && cd build && cmake ../ -Wno-dev && make -j4 && make && sudo make install && make clean && sudo ldconfig" \
   || { echo "Error: Failed to compile Stage. Aborting."; exit 1; }

  # Clean up
  container_exec $container_name apt-get -q remove -y $(cat "${container_config_dir}/build.list")
  container_expendables_import "$lib_container/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
