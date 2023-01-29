
# Derive from configured, stable Debian installation
architecture="amd64"
base_release="stable"
base_image="docker.io/matthiasbock/debian-base:${base_release}-${architecture}"

# Microsoft Teams version -> container tag
image_name="microsoft-teams"
image_tag="linux-$architecture-$(echo -n $(date +%Y-%m-%d))"
container_name="${image_name}-${image_tag}"

user="runner"

# Commit the result as image
image_config="USER=${user} WORKDIR=/home/${user} CMD=/bin/bash"
image_repositories="docker.io/matthiasbock/$image_name registry.bihealth.org:443/bockm/recipes/$image_name"


function container_setup()
{
  # Add Microsoft's package repository sources.list
  echo "Configuring Microsoft package repositories ..."
  srcfile="$shared_dir/config/apt/sources.list.d/microsoft.list"
  dstpath="/etc/apt/sources.list.d"
  dstfile="$dstpath/microsoft.list"
  container_add_file $container_name "$srcfile" "$dstfile" \
   || { echo "Error: Failed to copy sources.list to container. Aborting."; exit 1; }
  container_exec $container_name chown root.root "$dstfile" \
   || { echo "Error: Failed to change ownership of $dstfile. Aborting."; exit 1; }
  container_exec $container_name chmod 644 "$dstfile" \
   || { echo "Error: Failed to change permissions of $dstfile. Aborting."; exit 1; }

  # Import Microsoft's repo GPG key
  echo "Adding and trusing Microsoft's repo public key ..."
  srcfile="$shared_dir/keys/microsoft.asc"
  dstpath="/tmp"
  dstfile="$dstpath/microsoft.key"
  container_add_file $container_name "$srcfile" "$dstfile" \
   || { echo "Error: Failed to copy file to container. Aborting."; exit 1; }
  container_exec $container_name apt-key add /tmp/microsoft.asc

  # Fetch package list
  container_exec $container_name apt-get -q update

  # gdebi-core
  container exec $container_name apt-get -q install -y libsecret-1-0 teams
  mkdir -p "/home/$user/.config/Microsoft/Microsoft Teams/logs"
  touch "/home/$user/.config/Microsoft/Microsoft Teams/hooks.json"

  # Clean up
  container_expendables_import "${bash_container_library}/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
