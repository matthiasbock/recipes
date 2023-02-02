
image_name="compute"
image_tag="studies"

debian_release="bullseye"
debian_architecture="amd64"
base_image="registry.bihealth.org:443/bockm/recipes/testenv:python3"

container_name="${image_name}_${image_tag}"
container_architecture="$debian_architecture"

# Push image to repos
image_repositories="registry.bihealth.org:443/bockm/recipes/$image_name:$image_tag"


function container_setup() {
  # Install packages
  container_exec $container_name apt-get update -q || true
  container_install_requirements_txt $container_name "$container_config_dir/requirements.txt" || exit $?

  # Delete expendable files
  container_expendables_import "$bash_container_library/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
