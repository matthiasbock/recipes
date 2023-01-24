
# Derive from configured, stable Debian installation
export architecture="amd64"
export base_release="stable"
export base_image="docker.io/matthiasbock/debian-base:${base_release}-${architecture}"

# Microsoft Teams version -> container tag
export image_name="microsoft-teams"
export image_tag="linux-$architecture-$(echo -n $(date +%Y-%m-%d))"
export container_name="${image_name}-${image_tag}"

export user="runner"

# Commit the result as image
export image_config="USER=${user} WORKDIR=/home/${user} CMD=/bin/bash"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"


function container_setup()
{
  # Add Microsoft's package repository sources.list
  echo "Configuring Microsoft package repositories ..."
  srcfile="$common/config/apt/sources.list.d/microsoft.list"
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
  srcfile="$common/keys/microsoft.asc"
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
