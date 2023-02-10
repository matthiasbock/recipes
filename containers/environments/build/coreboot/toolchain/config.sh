
image_name="workenv"
image_tag="coreboot"

debian_release="bullseye"
debian_architecture="amd64"

container_name="${image_name}_${image_tag}"
container_architecture="$debian_architecture"

user="runner"
repo_dir="/home/$user/coreboot"
image_config="USER=$user WORKDIR=$repo_dir CMD=/bin/bash"

# Derive container from this image:
base_image="$BASE_IMAGE"

# Push resulting image to these repos:
image_repositories="$IMAGE_REPOSITORY $IMAGE_REPOSITORIES"


#
# TODO: Also pull the ccache from somewhere and append it to the container
#

function container_setup()
{
  # Build toolchain
  container_exec $container_name bash -c "cd '$repo_dir' && make $multi_threading iasl crossgcc"

  # Clean up
  container_expendables_import "$bash_container_library/assets/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
