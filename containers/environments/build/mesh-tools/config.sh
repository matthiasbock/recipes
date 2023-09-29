
image_name="buildenv"
image_tag="mesh-tools"

debian_release="bullseye"
debian_architecture="amd64"

container_name="${image_name}_${image_tag}"
container_architecture="$debian_architecture"

# Derive container from this image:
base_image="$BASE_IMAGE"

# Push resulting image to these repos:
image_repositories="$IMAGE_REPOSITORY $IMAGE_REPOSITORIES"


function container_setup() {
  # Install additional packages
  container_exec $container_name apt-get update -q || true
  container_install_dependencies_txt $container_name "$container_config_dir/dependencies.txt" || exit $?

  # Configure ccache
  # container_add_file $container_name $shared_dir/config/shell/ccache.sh /etc/profile.d/

  # Shrink to minimum size
  container_expendables_import "$lib_container/assets/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
