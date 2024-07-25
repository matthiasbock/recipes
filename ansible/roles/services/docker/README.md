
# Docker role

This role implements tasks to control Docker daemon as well as images and containers.

## Docker daemon

Actions:

* `get_docker_state`
* `restore_docker_state`
* `install_docker`
* `uninstall_docker`
* `start_docker`
* `stop_docker`
* `enable_docker`
* `disable_docker`

## Remote Docker daemon

Actions:

* `start_forwarding`: Forward a remote host's Docker unix socket to localhost. This enables interaction with images and containers using the respective Ansible modules.
* `stop_forwarding`: Stop the forwarding of a remote host's Docker unix socket to localhost.

## Docker image registry

Actions:

* `registry_login`

## Docker image

Actions:

* `build_image`
* `remove_image`
* `pull_image`
* `push_image`

## Docker container

Actions:

* `create_container`
* `remove_container`
* `start_container`
* `stop_container`
* `commit_container`
* `get_container_info`
* `assert_container_exists`

