
image_name="buildenv"
image_tag="simulations"

debian_release="bullseye"
debian_architecture="amd64"
base_image="docker.io/matthiasbock/debian:$debian_release-$debian_architecture"

container_name="${image_name}_${image_tag}"
container_architecture="linux/amd64"

# Build image using Dockerfile
# dockerfile="$container_config_dir/Dockerfile"

packages="time make gcc g++ clang llvm xvfb libgl1 vtk7 libvtk7-dev libvtk7-qt-dev python3-pip python3-vtk7"

# Push image to repos
image_repositories="docker.io/matthiasbock/$image_name:$image_tag registry.bihealth.org:443/bockm/recipes/$image_name:$image_tag"


function container_setup() {
  # Install additional packages
  container_exec $container_name apt-get update -q
  container_exec $container_name apt-get -qy install $packages
  container_exec $container_name pip3 install vtk pyvista pyvirtualdisplay gmsh

  # Expendables
  container_exec $container_name apt-get clean
  container_exec $container_name find /lost+found /run /tmp /root/.bash_history /home/*/.bash_history \
    /usr/share/doc /usr/local/share/doc /usr/share/icons /usr/share/man /usr/share/vim/vim81/doc \
   /var/cache/apt/archives /var/cache/fonts /var/cache/man /var/lib/apt/lists /var/lock \
   /var/log /var/mail /var/run /var/spool /var/tmp -type f -exec rm -fv {} \; || true
}
