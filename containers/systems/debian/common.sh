
image_name="debian"

# Derive container/image from this image
base_image="docker.io/debian:$debian_release-slim"
image_tag="${debian_release}-$target_architecture"
container_name="${image_name}_$image_tag"

# Container/image parameters
user="runner"
groups="runner sudo docker"

# This pool is used before package verification using GPG is available.
# Use a HTTPS package pool here to at least have transport encryption.
package_pool="https://ftp.gwdg.de/pub/linux/debian/debian/pool/"
sources_list="$common/config/apt/sources.list.d/$debian_release.list"

# Commit the result as image
image_config="USER=${user} WORKDIR=/home/${user} CMD=/bin/bash"


function container_setup()
{
  #
  # Configure bash, user and groups
  #
  echo "Creating new user $user ..."
  container_create_user $container_name $user $groups \
   || { echo "Error: Failed to create user. Aborting."; exit 1; }

  echo "Adding a .bashrc for root and $user ..."
  tmpfile=".bashrc"
  cat $common/config/shell/*.bashrc > "$tmpfile"
  container_add_file $container_name "$tmpfile" "/root/" \
   || { echo "Error: Failed to add bashrc for user root. Aborting."; exit 1; }
  container_exec $container_name chown -R root.root /root/ \
   || { echo "Error: Failed to change file ownership. Aborting."; exit 1; }
  container_add_file $container_name "$tmpfile" "/home/$user/" \
   || { echo "Error: Failed to add bashrc to user $user. Aborting."; exit 1; }
  container_exec $container_name chown -R ${user}.${user} "/home/$user/" \
   || { echo "Error: Failed to change file ownership. Aborting."; exit 1; }
  rm -f "$tmpfile"

  #
  # Configure APT and install packages
  #
  echo "Configuring APT ..."
  container_add_file $container_name $common/config/apt/apt.conf /etc/apt/apt.conf

  # Workaround for installation problems (e.g. with openjdk-11-jdk)
  $container_cli exec -t $container_name mkdir -p /usr/share/man/man1/

  # Manually facilitate SSL certificate verification
  for pkg in libncursesw6 dialog libssl1.1 openssl ca-certificates; do
    container_debian_download_package_and_install $container_name $pkg $debian_release $target_architecture
  done

  # Bootstrap using a trustworthy HTTPS package repository
  container_add_file $container_name "$sources_list" "/etc/apt/sources.list" \
   || { echo "Error: Failed to add apt sources.list required for further package installation. Aborting."; exit 1; }
  container_exec $container_name apt-get -q update
  # Clean up possible problems arising from the manual installation above
  container_exec $container_name apt-get -q -f -y install
  # Install keyrings to enable package verification
  container_exec $container_name apt-get -q -y install --reinstall ca-certificates debian-*keyring ubuntu-*keyring \
   || { echo "Error: Failed to install keyrings. Aborting."; exit 1; }
  # Make sure, we are using the latest stable version of all packages
  container_exec $container_name apt-get -q -y upgrade

  # Select fastest package repository
  #$container_cli exec -it -u root $container_name bash -c "apt-get -q update && apt-get -q install -y netselect-apt && netselect-apt -s"
  # TODO: netselect is not working from within the container
  # netselect: socket: Operation not permitted
  # You should be root to run netselect.
  # netselect was unable to operate successfully, please check the errors,
  # most likely you don't have enough permission.

  # Install additional packages
  container_debian_install_package_bundles debian-essentials console-tools \
   || { echo "Error: Failed to install packages. Aborting."; exit 1; }

  #
  # Configure ccache
  #
  container_exec $container_name mkdir -p /home/$user/.ccache
  container_exec $container_name ln -s ../home/$user/.ccache /root/.ccache
  container_exec $container_name chown $user.$user /home/$user/.ccache

  #
  # Add permission to use sudo without password
  #
  echo "Granting sudo priviledges to $user ..."
  srcfile="$common/config/sudoers.d/runner"
  dstpath="/etc/sudoers.d"
  dstfile="$dstpath/runner"
  container_add_file $container_name "$srcfile" "$dstfile" \
   || { echo "Error: Failed to copy sudoers config to container. Aborting."; exit 1; }
  container_exec $container_name chown root.root "$dstfile" \
   || { echo "Error: Failed to change ownership for $dstfile. Aborting."; exit 1; }
  container_exec $container_name chmod 440 "$dstfile" \
   || { echo "Error: Failed to change permissions for $dstfile. Aborting."; exit 1; }

  #
  # Clean up
  #
  container_expendables_import "${bash_container_library}/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
