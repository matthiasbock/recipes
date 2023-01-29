
architecture="amd64"
base_release="stable"
base_image="docker.io/matthiasbock/debian-base:${base_release}-${architecture}"

image_name="zoom"
image_tag="latest-$architecture"
container_name="${image_name}-${image_tag}"

user="runner"
image_config="USER=${user} WORKDIR=/home/${user} CMD=/bin/bash"
image_repositories="docker.io/matthiasbock/$image_name registry.bihealth.org:443/bockm/recipes/$image_name"

deb_url="https://zoom.us/client/latest/zoom_amd64.deb"


function container_setup()
{
  # Import GPG key
  echo "Adding GPG public key ..."
  srcfile="$shared_dir/keys/zoom.asc"
  dstfile="/tmp/zoom.key"
  container_add_file $container_name "$srcfile" "$dstfile" \
   || { echo "Error: Failed to copy file to container. Aborting."; exit 1; }
  container_exec $container_name apt-key add "$dstfile"

  # Prepare for installation
  container_exec $container_name apt-get -q update
  container_exec $container_name apt-get -q install -y gdebi-core

  # Fetch and install Zoom package
  echo "Fetching package ..."
  srcfile="/tmp/zoom.deb"
  wget --progress=dot:giga "$deb_url" -O "$srcfile"
  dstfile="/tmp/zoom.deb"
  container_add_file $container_name "$srcfile" "$dstfile" \
   || { echo "Error: Failed to copy file to container. Aborting."; exit 1; }
  echo "Installing package ..."
  container_exec $container_name gdebi --non-interactive $dstfile

  # Clean up
  container_exec $container_name apt-get -q purge -y gdebi
  container_exec $container_name apt-get -q autoremove -y
  container_expendables_import "${bash_container_library}/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
