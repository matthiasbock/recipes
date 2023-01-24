#!/bin/bash

set -x

set -e
cd $(dirname $0)
source ../common/container.sh
source include.sh
#set +e

create_volume "$volume_name"

# TODO: if necessary, execute
# podman pod create --name buildenv

function constructor()
{
#		--pod "$pod" \
	$cli run \
		--network=host \
		--name "$container_name" \
		-v "$volume_name:/var/cache/apt-cacher-ng" \
		--detach \
		$parent_repository

# TODO: Disable non-functional kernel logging in rsyslog:
# line
#  module(load="imklog")
# in /etc/rsyslogd.conf

	filename="rsyslog.conf"
	$cli cp ${container_name}:/etc/${filename} .
	cat ${filename} | fgrep -v 'module(load="imklog")' > ${filename}.patched
	mv ${filename}.patched ${filename}
	$cli cp ${filename} ${container_name}:/etc/
	rm ${filename}

#	&> /dev/null

#		--net $net \
#		--network-alias $apt_cache_container \
#		-p 3142:3142 \
}

create_container "$container_name" constructor

$cli cp deb-backup.sh "$container_name:/var/cache/apt-cacher-ng/"

