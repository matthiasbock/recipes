
image_name="testenv"
image_tag="python3"

debian_release="bullseye"
debian_architecture="amd64"
base_image="docker.io/matthiasbock/debian:$debian_release-$debian_architecture"

container_name="${image_name}_${image_tag}"
container_architecture="$debian_architecture"

# Required packages for Python
packages="$(cat $shared_dir/package-bundles/python3.list)"

# Additional often used packages, to be installed via apt-get
dependencies="$(cat "$container_config_dir/dependencies.txt")"

# Additional often used packages, to be installed via pip3
requirements="$(cat "$container_config_dir/requirements.txt")"

# Push image to repos
image_repositories="docker.io/matthiasbock/$image_name:$image_tag registry.bihealth.org:443/bockm/recipes/$image_name:$image_tag"


function container_setup() {
  # Install additional packages
  container_exec $container_name apt-get update -q
  container_exec $container_name apt-get -qy install $packages $dependencies
  container_exec $container_name pip3 install -q $requirements

  # Expendables
  container_exec $container_name apt-get clean
  container_exec $container_name find /lost+found /run /tmp /root/.bash_history /home/*/.bash_history \
    /usr/share/doc /usr/local/share/doc /usr/share/icons /usr/share/man /usr/share/vim/vim81/doc \
   /var/cache/apt/archives /var/cache/fonts /var/cache/man /var/lib/apt/lists /var/lock \
   /var/log /var/mail /var/run /var/spool /var/tmp -type f -exec rm -fv {} \; || true
}
