
FROM docker.io/matthiasbock/compute:compile

RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get update && \
    sudo apt-get install -q -y --no-install-recommends cuda && \
    sudo apt-get clean
