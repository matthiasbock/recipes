
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
requirements_file="$container_config_dir/requirements.txt"
requirements="$(cat "$requirements_file")"

# Push image to repos
image_repositories="registry.bihealth.org:443/bockm/recipes/$image_name:$image_tag"


function container_setup() {
  # Install additional packages
  echo -e "Installing packages from \"$requirements_file\" via pip3:\n$requirements"
  if [ "$requirements" == "" ]; then
    echo "Error: The list of requirements should not be empty."
    exit 1
  fi
  for requirement in $requirements; do
    echo -n "Installing $requirement ..."
    container_exec $container_name pip3 install -q $requirement \
    || { echo "Error: Installation failed."; exit 1; }
    echo "ok."
  done

  # Delete expendable files
  container_expendables_import "$bash_container_library/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
