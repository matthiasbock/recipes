
FROM docker.io/matthiasbock/ubuntu-base:focal-amd64

RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get update && \
    sudo apt-get purge -q -y systemd* dbus* xserver* xorg* gnome* evolution* ubuntu-wallpapers* firmware* *-driver bluez* cups* network* modem* wpasupplicant* avahi* && \
    sudo apt-mark hold systemd* dbus* xserver-xorg* xorg* gnome* evolution* ubuntu-wallpapers* firmware* *-driver bluez* cups* network* modem* wpasupplicant* avahi* && \
    sudo apt-get autoremove -q -y && \
    sudo apt-get upgrade -q -y --no-install-recommends && \
    sudo apt-get install -q -y --no-install-recommends \
      wget gnupg software-properties-common apt-utils apt-transport-https ca-certificates debian*-keyring ubuntu*-keyring && \
    sudo apt-get clean && \
    sudo wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin -O /etc/apt/preferences.d/cuda-repository-pin-600 && \
    sudo apt-key adv --fetch-keys "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub" && \
    sudo apt-key adv --fetch-keys "https://developer.download.nvidia.com/compute/cuda/repos/GPGKEY" && \
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A4B469963BF863CC && \
    sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" && \
    sudo apt-get update
