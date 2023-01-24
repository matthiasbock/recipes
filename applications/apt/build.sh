#!/bin/bash

source ../../common/bash-container-library/library.sh

if ! container_exists buildenv-apt; then
  $container_cli create -it -v ccache:/home/runner/.ccache docker.io/matthiasbock/buildenv-apt:buster-amd64 buildenv-apt
fi
