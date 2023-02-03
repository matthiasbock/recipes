#!/bin/bash

set -e
cd "$(dirname $0)"

source ../common/container.sh
source ../apt-cache/conf.sh
source ../debian-base/conf.sh

# Out config must be the last
source conf.sh
set +e


#
# Bind sources
#
src_host="$(echo -n ~)/src"
src_container="/usr/local/src"

#
# List of package bundles to install in the container
#
#package_bundles="version-control build-tools"
additional_packages="git meson ninja ccache wget flex bison autoconf gcc-aarch64-linux-gnu libaio-dev libbluetooth-dev libbrlapi-dev libbz2-dev libcap-dev libcap-ng-dev libcurl4-gnutls-dev libepoxy-dev libfdt-dev libgbm-dev libgles2-mesa-dev libglib2.0-dev libibverbs-dev libjpeg62-turbo-dev liblzo2-dev libncurses5-dev libnuma-dev librbd-dev librdmacm-dev libsasl2-dev libsdl1.2-dev libsdl2-dev libseccomp-dev libsnappy-dev libssh2-1-dev libtool libusb-1.0-0 libusb-1.0-0-dev libvde-dev libvdeplug-dev libvte-dev libxen-dev valgrind xfslibs-dev xutils-dev zlib1g-dev"


# Create ccache volume, if necessary
create_volume ccache

#
# Create the container
#
function constructor()
{
#	if ! image_exists "$base_image"; then
#	fi
	$cli create \
		-it \
		--pod $pod \
		--name $container_name \
		--volumes-from $base_image \
		-v ccache:/root/.ccache \
		-v ccache:/home/$user/.ccache \
		-v $src_host:$src_container \
		--workdir /home/$user \
		--user $user \
		$base_image

#		--net $net \
#		--network-alias $container_name \
}
container_create $container_name constructor || exit 1


# Start the container
$cli start $container_name &> /dev/null

#
# Install additional packages
#
#install_package_bundles $package_bundles
$cli exec -it -u root $container_name apt update || exit 1
install_packages $additional_packages || exit 1

# Cleanup
$cli exec -it -u root $container_name rm -f /root/.bash_history /home/$user/.bash_history

# Done
echo "Container \"$container_name\" created successfully."
$cli stop $container_name &> /dev/null

# Commit
container_commit $container_name


