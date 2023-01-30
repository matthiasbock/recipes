
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
function add_bashrc() {
  echo "Adding a .bashrc for root and $user ..."
  tmpfile=".bashrc"
  cat $shared_dir/config/shell/*.bashrc > "$tmpfile"
  container_add_file $container_name "$tmpfile" "/root/" \
   || { echo "Error: Failed to add bashrc for user root."; exit 1; }
  container_add_file $container_name "$tmpfile" "/home/$user/" \
   || { echo "Error: Failed to add bashrc to user $user."; exit 1; }
  rm -f "$tmpfile"
}

#
# Use the base image's sources.list to
# install all packages required for SSL transport encryption
#
function enable_ssl_support() {
  set +e

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

  set -e
}

#
# Use SSL encrypted package repo to download the packages
# required for package verification
#
function enable_package_verification() {
  # Removed insecure HTTP package repo
  container_rm_file $container_name /etc/apt/sources.list

  # Add HTTPS package repository
  container_add_file $container_name "$sources_list" "/etc/apt/sources.list" \
  || { echo "Error: Failed to add \"$sources_list\" to container \"$container_name\"."; exit 2; }

  # Update the package cache
  container_exec $container_name apt-get -q update

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
    bundles="$bundles $shared_dir/package-bundles/${bundle}.list"
  done
  container_debian_install_package_bundles $bundles
  local retval=$?
  [[ $retval == 0 ]] || { echo "Error: Failed to install package bundles (error $retval)."; exit $retval; }
}

#
# Add permission to use sudo without password
#
function grant_sudo_priviledges() {
  echo "Granting sudo priviledges to $user ..."

  # Copy sudoers config from shared directory to container
  srcfile="$shared_dir/config/sudoers.d/runner"
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
}
