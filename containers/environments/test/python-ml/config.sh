
image_name="testenv"
image_tag="python-ml"

debian_release="bullseye"
debian_architecture="amd64"

container_name="${image_name}_${image_tag}"
container_architecture="$debian_architecture"

# Derive container from this image:
base_image="registry.bihealth.org:443/bockm/recipes/testenv:python3"

# Push resulting image to these repos:
image_repositories="registry.bihealth.org:443/bockm/recipes/${image_name}:${image_tag}"


#
# Customize the container as needed
#
function container_setup() {
  # Update package lists
  container_exec $container_name apt-get update -q || true

  # Install system dependencies
  container_install_dependencies_txt $container_name "$container_config_dir/dependencies.txt" || exit $?

  # Install Python requirements
  container_install_requirements_txt $container_name "$container_config_dir/requirements.txt" || exit $?

  # Delete expendable files
  container_expendables_import "$assets_dir/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
