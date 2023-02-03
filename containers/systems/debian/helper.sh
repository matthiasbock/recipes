
#
# Create a user which is member in the specified groups
# (missing groups are created)
#
function add_user() {
  echo "Creating new user \"$user\" ..."
  [[ "$container_name" != "" ]] || exit 2
  [[ "$user" != "" ]] || exit 3
  [[ "$groups" != "" ]] || exit 4

  container_create_user $container_name $user $groups \
   || { echo "Error: Failed to create user."; exit 5; }
}

#
# Configure the shell
#
function configure_shell() {
  src_profile="path color git bash-completion debconf proxy ccache ssh-keygen shortcuts"
  src_bashrc_root="ssh-host-keygen apt-update"

  echo -n "Configuring global shell profile..."
  for file in $src_profile; do
    local filepath="$assets_dir/etc/profile.d/${file}.sh"
    container_add_file $container_name $filepath /etc/profile.d/ \
    || { echo "Error: Failed to add file to container."; exit 2; }
  done
  echo "done."

  echo -n "Creating .bashrc for root and $user ... "
  tmpfile=".bashrc"
  rm -f $tmpfile
  # for file in $src_bashrc_root; do
  #   local filepath="$assets_dir/etc/profile.d/${file}.sh"
  #   cat $filepath >> $tmpfile
  # done
  echo ". /etc/profile" > $tmpfile
  container_add_file $container_name $tmpfile /root/ \
  || { echo "Error: Failed to add file to container."; exit 3; }
  container_add_file $container_name $tmpfile /home/$user/ \
  || { echo "Error: Failed to add file to container."; exit 4; }
  rm -vf $tmpfile
  echo "done."
}

#
# Install all packages required for SSL transport encryption
# without invoking apt or apt-get
#
function enable_ssl_support() {

  # Get target release
  local release
  if [ "$debian_release" != "" ]; then
    release=$debian_release
  elif [ "$ubuntu_release" != "" ]; then
    release=$ubuntu_release
  else
    echo "Error: Target release is not defined."
    exit 2
  fi

  # Manually facilitate SSL certificate verification
  for pkg in $bootstrap_packages; do
    echo "Installing $pkg without verification ..."
    container_debian_download_package_and_install $container_name $pkg $release $target_architecture
    local retval=$?
    [[ $retval == 0 ]] || { echo "Error: Installation failed (error $retval)."; exit $retval; }
  done
}

#
# Add trusted public keys to the container
#
function add_public_keys() {
  # Create target folder
  local target_folder="/etc/apt/trusted.gpg.d/"
  container_exec $container_name mkdir -p $target_folder

  # List available keys
  if ! is_set keys_dir; then
    local keys_dir="$assets_dir/keys"
  fi
  for keyfile in $(ls -1 $keys_dir); do
    local filepath=$keys_dir/$keyfile
    echo -n "Installing public key: \"$filepath\"... "

    # Copy key to container
    container_add_file $container_name $filepath $target_folder \
    || { echo "Error: Failed to add file to container."; exit 2; }

    # Install key to keyring
    # container_exec $container_name apt-key add /tmp/$keyfile

    echo "ok."
  done

  # Adjust permissions
  container_exec $container_name chmod -R o+w $target_folder/
  container_exec $container_name chmod -R ga-w $target_folder/

  # Update the package list
  container_exec $container_name apt-get -q update
}

#
# Add apt sources.list files to container
#
function add_sources_lists() {

  # Remove insecure HTTP package repo
  container_exec $container_name rm -vf /etc/apt/sources.list

  # Add HTTPS package repository
  for file in $apt_sources_lists; do
    local filepath="$assets_dir/debian/apt/sources.list.d/$file.list"
    container_add_file $container_name "$filepath" /etc/apt/sources.list.d/ \
    || { echo "Error: Failed to add \"$filepath\" to container."; exit 20; }
  done

  # Update the package list
  container_exec $container_name apt-get -q update
}

#
# Use SSL encrypted package repo to download the packages
# required for package verification
#
function enable_package_verification() {

  # Clean up possible any problems potentially arisen from the manual installations in enable_ssl_support()
  container_exec $container_name apt-get -q -f -y install

  # Install keyrings
  container_exec $container_name apt-get -q -y install debian-*keyring ubuntu-*keyring \
  || { echo "Error: Failed to install keyrings."; exit 3; }

  # Re-install all installed packages, this time using verification
  container_exec $container_name apt-get -q -y install --reinstall $bootstrap_packages debian-*keyring ubuntu-*keyring \
  || { echo "Error: Failed to re-install packages."; exit 4; }
}

#
# Install the configured package bundles
#
function install_package_bundles() {
  local bundles=""
  for bundle in $package_bundles; do
    bundles="$bundles $assets_dir/debian/package-bundles/$bundle.list"
  done
  container_debian_install_package_bundles $container_name $bundles
  local retval=$?
  [[ $retval == 0 ]] || { echo "Error: Failed to install package bundles (error $retval)."; exit $retval; }
}

#
# Add permission to use sudo without password
#
function grant_sudo_priviledges() {
  echo "Granting sudo priviledges to $user ..."

  # Copy sudoers config from shared directory to container
  srcfile="$assets_dir/etc/sudoers.d/runner"
  dstpath="/etc/sudoers.d"
  dstfile="$dstpath/runner"
  container_add_file $container_name "$srcfile" "$dstfile" \
  || { echo "Error: Failed to copy sudoers config to container."; exit 2; }

  # Adjust file permissions
  container_exec $container_name chmod 440 "$dstfile" \
  || { echo "Error: Failed to change permissions for $dstfile."; exit 4; }
}

#
# Ensuring proper ownerships
#
function verify_ownerships() {
  # Everything in the user's home folder belongs to the user
  local home="/home/$user/"
  container_exec $container_name chown -R $user.$user "$home" \
  || { echo "Error: Failed to adjust ownership of \"$home\"."; exit 2; }

  # Everything in root's home folder belongs to root
  container_exec $container_name chown -R root.root /root \
  || { echo "Error: Failed to adjust ownership of \"/root\"."; exit 3; }

  # All configuration belongs to root
  container_exec $container_name chown -R root.root /etc \
  || { echo "Error: Failed to adjust ownership of \"/etc\"."; exit 4; }

  # Configuration should only be writeable by root
  container_exec $container_name chmod -R ga-w /etc \
  || { echo "Error: Failed to adjust permissions of \"/etc\"."; exit 5; }
}
