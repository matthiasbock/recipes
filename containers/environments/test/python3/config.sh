
image_name="testenv"
image_tag="python3"

debian_release="bullseye"
debian_architecture="amd64"

base_image="debian"
#base_image="docker.io/matthiasbock/$base_image:$debian_release-$debian_architecture"
base_image="registry.bihealth.org:443/bockm/recipes/$base_image:$debian_release-$debian_architecture"

container_name="${image_name}_${image_tag}"
container_architecture="$debian_architecture"

# Push image to repos
# docker.io/matthiasbock/$image_name:$image_tag
image_repositories="registry.bihealth.org:443/bockm/recipes/$image_name:$image_tag"


function container_setup() {
  # Install additional packages
  container_exec $container_name apt-get update -q || true
  container_install_package_bundles $container_name python3 || exit $?
  container_install_dependencies_txt $container_name "$container_config_dir/dependencies.txt" || exit $?
  container_install_requirements_txt $container_name "$container_config_dir/requirements.txt" || exit $?

  # Delete expendable files
  container_expendables_import "$bash_container_library/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
