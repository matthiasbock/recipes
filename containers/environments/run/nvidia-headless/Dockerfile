
FROM docker.io/matthiasbock/compute:compile

RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get update && \
    sudo apt-get install -q -y nvidia-headless-no-dkms-495 && \
    sudo apt-get clean
