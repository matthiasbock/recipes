#!/bin/bash

podman create -it --name buildenv-openssh-server-amd64 -v ccache:/home/runner/.ccache docker.io/matthiasbock/buildenv-openssh-server:amd64

podman start buildenv-openssh-server-amd64

podman exec -it -u root buildenv-openssh-server-amd64 chown -R runner:runner /home/runner/
podman exec -it -u root buildenv-openssh-server-amd64 ./run.sh

podman stop buildenv-openssh-server-amd64
