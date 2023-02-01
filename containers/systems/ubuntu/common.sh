
image_name="ubuntu"

# Derive container/image from this image
image_tag="$ubuntu_release-$target_architecture"
container_name="${image_name}_${image_tag}"
container_architecture="linux/$target_architecture"

# Container/image parameters
user="runner"
groups="runner sudo docker"

image_config="USER=${user} WORKDIR=/home/${user} CMD=/bin/bash"
# docker.io/matthiasbock/$image_name:$image_tag
image_repositories="registry.bihealth.org:443/bockm/recipes/$image_name:$image_tag"


function container_setup()
{
  # Configure bash
  echo "Creating new user $user ..."
  container_create_user $container_name "$user" \
   || { echo "Error: Failed to create user. Aborting."; exit 1; }

  echo "Adding a .bashrc for root and $user ..."
  tmpfile=".bashrc"
  cat $shared_dir/config/shell/*.bashrc > "$tmpfile"
  container_add_file $container_name "$tmpfile" "/root/" \
   || { echo "Error: Failed to add bashrc for user root. Aborting."; exit 1; }
  container_exec $container_name chown -R root.root /root/ \
   || { echo "Error: Failed to change file ownership. Aborting."; exit 1; }
  container_add_file $container_name "$tmpfile" "/home/$user/" \
   || { echo "Error: Failed to add bashrc to user $user. Aborting."; exit 1; }
  container_exec $container_name chown -R ${user}.${user} "/home/$user/" \
   || { echo "Error: Failed to change file ownership. Aborting."; exit 1; }
  rm -f "$tmpfile"

  # Prepare ccache folder
  container_exec $container_name mkdir -p /home/$user/.ccache
  container_exec $container_name ln -s ../home/$user/.ccache /root/.ccache
  container_exec $container_name chown $user.$user /home/$user/.ccache

  # Configure APT
  echo "Configuring APT ..."

  container_add_file $container_name $shared_dir/config/apt/apt.conf /etc/apt/apt.conf

  container_exec $container_name echo 'APT::Get::Install-Recommends "false"; APT::Get::Install-Suggests "false";' >> /etc/apt/apt.conf
  container_exec $container_name apt-get -q update

  # Workaround for installation problems (e.g. with openjdk-11-jdk)
  container_exec $container_name mkdir -p /usr/share/man/man1/

  container_exec $container_name apt-get -q install -y sudo dialog ca-certificates debian-*keyring ubuntu-*keyring vim bash bash-completion
  container_exec $container_name sudo DEBIAN_FRONTEND=noninteractive apt-get -q install -y tzdata keyboard-configuration

  # Enable sudo without password
  echo "Granting sudo priviledges to $user ..."
  srcfile="$shared_dir/config/sudoers.d/runner"
  dstpath="/etc/sudoers.d"
  dstfile="$dstpath/runner"
  container_add_file $container_name "$srcfile" "$dstfile" \
   || { echo "Error: Failed to copy sudoers config to container. Aborting."; exit 1; }
  container_exec $container_name chown root.root "$dstfile" \
   || { echo "Error: Failed to change ownership for $dstfile. Aborting."; exit 1; }
  container_exec $container_name chmod 440 "$dstfile" \
   || { echo "Error: Failed to change permissions for $dstfile. Aborting."; exit 1; }

  # Clean up
  container_expendables_import "${bash_container_library}/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
