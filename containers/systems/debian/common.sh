
image_name="debian"

# Derive container/image from this image
base_image="docker.io/debian:${debian_release}-slim"
image_tag="${debian_release}-$target_architecture"
container_name="${image_name}_${image_tag}"

# Container/image parameters
user="runner"
groups="runner sudo docker"

# This pool is used before package verification using GPG is available.
# Use a HTTPS package pool here to at least have transport encryption.
bootstrap_packages="libncursesw6 dialog libssl1.1 openssl ca-certificates apt-transport-https"
package_pool="https://ftp.gwdg.de/pub/linux/debian/debian/pool/"
sources_list="$shared_dir/config/apt/sources.list.d/$debian_release.list"
package_bundles="debian-essentials console-tools"

# Commit the result as image
image_config="USER=$user WORKDIR=/home/$user CMD=/bin/bash"
image_repositories="docker.io/matthiasbock/debian registry.bihealth.org:443/bockm/recipes/debian"

# Source the helper functions
helper="$container_config_dir/helper.sh"
echo "Importing helper functions from \"$helper\"..."
. "$helper" \
|| { echo "Error: Failed to import helper functions."; exit 2; }


#
# This function is called by the build script
# in order to populate the newly created container
#
function container_setup() {
  #
  # Configure bash, user and groups
  #
  add_user
  configure_shell

  #
  # Configure APT and install packages
  #
  echo "Configuring apt ..."
  container_add_file $container_name $shared_dir/config/apt/apt.conf /etc/apt/apt.conf

  # Workaround for installation problems (e.g. with openjdk-11-jdk)
  $container_cli exec -t $container_name mkdir -p /usr/share/man/man1/

  # Install packages required for SSL transport encryption
  enable_ssl_support

  # Install packages required for Debian package verification (via checksum and cryptographic signature)
  enable_package_verification

  # Select fastest package repository
  #$container_cli exec -it -u root $container_name bash -c "apt-get -q update && apt-get -q install -y netselect-apt && netselect-apt -s"
  # TODO: netselect is not working from within the container
  # netselect: socket: Operation not permitted
  # You should be root to run netselect.
  # netselect was unable to operate successfully, please check the errors,
  # most likely you don't have enough permission.

  # Make sure, we are using the latest stable version of all packages
  container_exec $container_name apt-get -q -y upgrade

  # Install additional packages
  install_package_bundles

  #
  # Configure ccache
  #
  container_exec $container_name mkdir -p /home/$user/.ccache
  container_exec $container_name ln -s ../home/$user/.ccache /root/.ccache
  container_exec $container_name chown $user.$user /home/$user/.ccache

  # runner may use sudo without password
  grant_sudo_priviledges

  # Make sure all files and folders have the proper ownership
  verify_ownerships

  #
  # Clean up
  #
  container_expendables_import "$bash_container_library/expendables/default.list"
  container_expendables_delete $container_name $container_expendables 2>/dev/null
}
