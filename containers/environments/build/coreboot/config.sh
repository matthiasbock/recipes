
image_name="buildenv"
image_tag="coreboot"

debian_release="bullseye"
debian_architecture="amd64"
base_image="docker.io/matthiasbock/debian:$debian_release-$debian_architecture"

container_name="${image_name}_${image_tag}"
container_architecture="$debian_architecture"

user="runner"

repo_uri="https://review.coreboot.org/coreboot.git"
repo_dir="/home/$user/coreboot"

image_config="USER=$user WORKDIR=$repo_dir CMD=/bin/bash"

image_repositories="docker.io/matthiasbock/$image_name:$image_tag registry.bihealth.org:443/bockm/recipes/$image_name:$image_tag"


#
# TODO: Also pull the ccache from somewhere and append it to the container
#

function container_setup()
{
  # Install build dependencies
  container_exec $container_name apt-get -q update || true
  container_install_dependencies_txt $container_name "$container_config_dir/dependencies.txt" || exit $?

  # Clone coreboot source repo
  container_exec $container_name git clone -q --depth=1 --recurse-submodules $repo_uri $repo_dir \
  || { echo "Failed to clone primary repository. Aborting."; exit 1; }
  container_exec $container_name chown -R $user.$user /home/$user || true

  # Clean up
  container_expendables_import "$bash_container_library/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
