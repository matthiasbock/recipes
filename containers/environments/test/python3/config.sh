
image_name="testenv"
image_tag="python3"

debian_release="bullseye"
debian_architecture="amd64"

base_image="debian"
#base_image="docker.io/matthiasbock/$base_image:$debian_release-$debian_architecture"
base_image="registry.bihealth.org:443/bockm/recipes/$base_image:$debian_release-$debian_architecture"

container_name="${image_name}_${image_tag}"
container_architecture="$debian_architecture"

# Required packages for Python
packages="$(cat $shared_dir/package-bundles/python3.list)"

# Additional often used packages, to be installed via apt-get
dependencies="$(cat "$container_config_dir/dependencies.txt")"

# Additional often used packages, to be installed via pip3
requirements="$(cat "$container_config_dir/requirements.txt")"

# Push image to repos
# docker.io/matthiasbock/$image_name:$image_tag
image_repositories="registry.bihealth.org:443/bockm/recipes/$image_name:$image_tag"


function container_setup() {
  # Install additional packages
  container_exec $container_name apt-get update -q
  container_exec $container_name apt-get -qy install $packages $dependencies
  container_exec $container_name pip3 install -q $requirements

  # Delete expendable files
  container_expendables_import "$bash_container_library/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
