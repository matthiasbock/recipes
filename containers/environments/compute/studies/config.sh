
image_name="compute"
image_tag="studies"

debian_release="bullseye"
debian_architecture="amd64"
base_image="registry.bihealth.org:443/bockm/recipes/testenv:python3"

container_name="${image_name}_${image_tag}"
container_architecture="$debian_architecture"

# Build image using Dockerfile
# dockerfile="$container_config_dir/Dockerfile"

# Required packages for Python
packages="$(cat $shared_dir/package-bundles/python3.list)"

# Additional often used packages, to be installed via apt-get
# dependencies="$(cat "$container_config_dir/dependencies.txt")"

# Additional often used packages, to be installed via pip3
requirements="$(cat "$container_config_dir/requirements.txt")"

# Push image to repos
image_repositories="registry.bihealth.org:443/bockm/recipes/$image_name:$image_tag"


function container_setup() {
  # Install additional packages
  container_exec $container_name pip3 install -q $pip_packages

  # Delete expendable files
  container_expendables_import "$bash_container_library/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
