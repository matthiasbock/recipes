
image_name="testenv"
image_tag="bash-container-library"

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
  container_install_dependencies_txt $container_name "$lib_container/test-dependencies.txt" || exit $?

  # Delete expendable files
  container_expendables_import "$assets_dir/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
