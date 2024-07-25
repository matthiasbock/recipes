
# Debian GNU/Linux OS

## Use cases

This role implements:

* bootstrapping a new Debian system installation, either
  * using debootstrap or
  * via a minimal installation system delivered via NFS after PXE boot.
* downloading Debian CDs, DVDs and pre-compiled images via https or jigdo and aria2
* resolving Debian package versions and URLs by release name
* downloading Debian packages
* using such files to bootstrap a new system
* composing a customizable Debian container image

## Supported target systems

The target system can be:

* an existing system with a connectable SSH daemon
  * for post-bootstrap and configuration tasks
* a root filesystem in a Docker container
  * by forwarding the respective Docker daemon's unix socket via SSH, if necessary, and
  * using connection type docker
* a root filesystem in a regular folder
  * when invoking debootstrap
  * otherwise via systemd-nspawn
  * optionally using a statically compiled qemu, if virtualization is required
* a binary disk or partition image
  * using losetup to set-up mountable loopback devices
  * using partprobe to find partitions
  * operating on the mounted folder as described above (debootstrap/system-nspawn+qemu)

