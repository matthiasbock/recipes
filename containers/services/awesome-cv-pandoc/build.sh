#!/bin/bash

set -e
cd $(dirname $0)

source ../common/container.sh
source ../common/packages.sh

source ../apt-cache/include.sh
apt_cache_container="$container_name"

source ../debian-base/include.sh
debian_base_container="$container_name"

source ../buildenv-base/include.sh
buildenv_base_container="$container_name"

../buildenv-base/build.sh

source include.sh

export path_project="$sources_dir/$project_name"

#set +e


if container_exists "$container_name"; then
	echo "Container '$container_name' already exists. Skipping."
	exit 0
fi

# Create container
function constructor()
{
	$cli create \
		-t \
		--pod "$pod" \
		--name "$container_name" \
		--volumes-from "$base_image" \
		-u "$user" \
		-w "$sources_dir" \
		"$base_image"
}
container_create "$container_name" constructor

# Rename host
container_start "$apt_cache_container"
container_start "$debian_base_container"
container_start "$buildenv_base_container"
container_start "$container_name"
container_set_hostname "$container_name" "$container_name"

# Workaround for missing dirs
$cli exec -t -u root -w / "$container_name" bash -c "mkdir -p /tmp /var/tmp /var/log /var/lock /usr/share/man/man1; chmod 777 /tmp -R;" || :

# Install build dependencies
remove_packages "openjdk-11-*"
install_packages "$build_dependencies"

# Clone repo, if necessary
$cli exec -t -w "/home/$user" "$container_name" bash -c "mkdir -p \"$path_project\" && cd \"$path_project\" && if [ -e \"$repo\" ]; then cd \"$repo\"; git pull; else git clone \"$git_url\" \"$repo\"; fi"

set -x
remove_packages aptitude subversion mercurial
#purge_force_depends dmsetup systemd

container_minimize "$container_name"

#container_commit $name

