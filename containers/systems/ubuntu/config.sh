
target_architecture="$ARCHITECTURE"
container_architecture="$ARCHITECTURE"

# Container/image parameters
image_name="ubuntu"
image_tag="$RELEASE-$ARCHITECTURE"
container_name="${image_name}_${image_tag}"

user="runner"
groups="runner sudo docker"

image_config="USER=${user} WORKDIR=/home/${user} CMD=/bin/bash"

# Derive container from this image:
base_image="$BASE_IMAGE"

# Push resulting image to these repos:
image_repositories="$IMAGE_REPOSITORY $IMAGE_REPOSITORIES"

# Source some helper functions
. "$container_config_dir/../debian/helper.sh"


function container_setup()
{
  add_user
  configure_shell

  #
  # Configure APT and install packages
  #
  echo "Configuring apt ..."
  container_add_file $container_name "$assets_dir/debian/apt/apt.conf" /etc/apt/apt.conf || exit $?

  # Workaround for installation problems (e.g. with openjdk-11-jdk)
  $container_cli exec -t $container_name mkdir -p /usr/share/man/man1/

  container_exec $container_name apt-get -q update

  container_exec $container_name apt-get -q install -y sudo dialog ca-certificates debian-*keyring ubuntu-*keyring vim bash bash-completion
  container_exec $container_name DEBIAN_FRONTEND=noninteractive apt-get -q install -y tzdata keyboard-configuration

  # Make sure, we are using the latest stable version of all packages
  container_exec $container_name apt-get -q -y upgrade

  #
  # Prepare for a possible installation of ccache
  #
  container_exec $container_name mkdir -p /home/$user/.ccache
  container_exec $container_name ln -s ../home/$user/.ccache /root/.ccache
  container_exec $container_name chown $user.$user /home/$user/.ccache

  # runner may use sudo without password
  grant_sudo_priviledges

  # Make sure all files and folders have the proper ownership
  verify_ownerships

  # Clean up
  container_expendables_import "${bash_container_library}/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
