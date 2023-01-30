
image_name="buildenv"
image_tag="mesh-tools"

debian_release="bullseye"
debian_architecture="amd64"
base_image="docker.io/matthiasbock/debian:$debian_release-$debian_architecture"

container_name="${image_name}_${image_tag}"
container_architecture="$debian_architecture"

# Build dependencies
dependencies="$(cat "$container_config_dir/dependencies.txt")"

# Push image to repos
image_repositories="registry.bihealth.org:443/bockm/recipes/$image_name:$image_tag"


function container_setup() {
  # Install additional packages
  container_exec $container_name apt-get update -q
  container_exec $container_name apt-get -qy install $packages $dependencies

  # Configure ccache
  # container_add_file $container_name $shared_dir/config/shell/ccache.sh /etc/profile.d/

  # Shrink to minimum size
  container_expendables_import "$bash_container_library/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
