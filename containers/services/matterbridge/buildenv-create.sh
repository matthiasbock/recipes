#!/bin/bash

set -e
cd $(dirname $0)

source ../common/container.sh
source ../common/packages.sh

source ../apt-cache/include.sh
apt_cache_container="$container_name"
../apt-cache/backup.sh

source ../debian-base/include.sh
debian_base_container="$container_name"

source ../buildenv-base/include.sh
buildenv_base_container="$container_name"

source include.sh

#set +e


if ! container_exists "$container_name"; then

	../buildenv-base/build.sh

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

	source include.sh
fi

#container_start "$apt_cache_container"
#container_start "$debian_base_container"
#container_start "$buildenv_base_container"
#container_start "$container_name"

# Rename host
container_set_hostname "$container_name" "$container_name"

# Workaround for missing dirs
$cli exec -t -u root -w / "$container_name" bash -c "mkdir -p /tmp /var/tmp /var/log /usr/share/man/man1; chmod 777 /tmp -R;" || :

# Workaround for missing PATH definition
$cli exec -t -u worker -w "/home/$user" "$container_name" echo "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH" >> .bashrc

# Install build dependencies
install_packages "$build_dependencies"
../apt-cache/backup.sh
remove_packages aptitude subversion mercurial dmsetup systemd make gradle 

# Clone repo, if necessary
$cli exec -t -u "$user" -w "/home/$user" "$container_name" bash -c "mkdir -p \"$path_project\" && cd \"$path_project\" && if [ -e \"$repo\" ]; then cd \"$repo\"; git pull; else git clone \"$git_url\" \"$repo\"; fi"

container_minimize "$container_name"

#container_commit $name

