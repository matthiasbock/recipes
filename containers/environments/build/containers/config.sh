
image_name="buildenv"
image_tag="containers"

debian_release="bullseye"
debian_architecture="amd64"
base_image="docker.io/matthiasbock/debian:$debian_release-$debian_architecture"

container_name="${image_name}_${image_tag}"
container_architecture="$debian_architecture"

# Push image to repos
image_repositories="docker.io/matthiasbock/$image_name:$image_tag registry.bihealth.org:443/bockm/recipes/$image_name:$image_tag"


function container_setup() {
  # Install additional packages
  container_exec $container_name apt-get update -q || true

  # Dependencies file from bash-container-library
  container_install_dependencies_txt $container_name "$project_root/dependencies.txt" || exit $?

  # Delete expendable files
  container_expendables_import "$bash_container_library/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
