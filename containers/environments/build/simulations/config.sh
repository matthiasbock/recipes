
image_name="buildenv"
image_tag="simulations"

debian_release="bullseye"
debian_architecture="amd64"
base_image="docker.io/matthiasbock/debian:$debian_release-$debian_architecture"

container_name="${image_name}_${image_tag}"
container_architecture="$debian_architecture"

# Build image using Dockerfile
# dockerfile="$container_config_dir/Dockerfile"

deb_packages="time make gcc g++ clang llvm xvfb libgl1 vtk7 libvtk7-dev libvtk7-qt-dev python3-pip python3-vtk7"
pip_packages="vtk pyvista pyvirtualdisplay gmsh"

# Push image to repos
image_repositories="docker.io/matthiasbock/$image_name:$image_tag registry.bihealth.org:443/bockm/recipes/$image_name:$image_tag"


function container_setup() {
  # Install additional packages
  container_exec $container_name apt-get update -q
  container_exec $container_name apt-get -qy install $deb_packages
  container_exec $container_name pip3 install $pip_packages

  # Delete expendable files
  container_expendables_import "$bash_container_library/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
