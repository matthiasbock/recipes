
# Derive container/image from this image
export image_name="dovecot"
export release="stable"
export architecture="amd64"
export base_image="docker.io/matthiasbock/debian-base:${release}-${architecture}"
export image_tag="latest"
export container_name="${image_name}-${image_tag}"

# Commit the result as image
export image_config="USER=root WORKDIR=/ ENTRYPOINT=['/usr/sbin/dovecot','-F','-c','/etc/dovecot/dovecot.conf']"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"


function container_setup()
{
  container_exec $container_name apt-get -q update
  container_exec $container_name apt-get -q install -y dovecot-imapd

  # Clean up
  container_expendables_import "$lib_container/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
