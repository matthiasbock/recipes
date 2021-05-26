#!/bin/bash

set -e
cd "$(dirname $0)"

source ../common/container.sh

source ../apt-cache/include.sh
apt_cache_container="$container_name"

source ../debian-base/include.sh
debian_base_container="$container_name"
debian_base_image="$image_name"

../debian-base/build.sh

source include.sh
#set +e


# Create ccache volume, if necessary
create_volume "$ccache_volume_name"

# Create artifact volume, if necessary
create_volume "$artifacts_volume_name"

if container_exists "$container_name"; then
	echo "Container '$container_name' already exists. Skipping."
	exit 0
fi

#
# Create the container
#
function constructor()
{
	$cli create \
		-t \
		--pod "$pod" \
		--name "$container_name" \
		--volumes-from "$debian_base_container" \
		-v "$sources_dir_host:$sources_dir" \
		-v "$ccache_volume_name:/root/.ccache" \
		-v "$ccache_volume_name:/home/$user/.ccache" \
		-v "$artifacts_volume_name:$artifacts_dir" \
		--user "$user" \
		--workdir "$workdir" \
		"$base_image"

#		--net $net \
#		--network-alias $container_name \
}
create_container $container_name constructor || exit 1


# Start the container
$cli start "$container_name" &> /dev/null
container_set_hostname "$container_name" "$container_name"

$cli exec -t -u root -w / "$container_name" bash -c "mkdir -p /root/.ccache /home/$user/.ccache $workdir $sources_dir $artifacts_dir"

#
# Install additional packages
#
install_package_bundles $package_bundles

# Done
echo "Successfully created container $container_name."

# Commit
container_minimize "$container_name"
$cli stop $container_name &> /dev/null
container_commit "$container_name"

