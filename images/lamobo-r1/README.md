
# BananaPi Lamobo R1

Makefiles for building a bootable Debian GNU/Linux image for the Lamobo R1.
The image is created by combining bootloader and base system from johang.se
with contents from a Debian Live/Install DVD.

## Hardware

* SoC: Allwinner A20
* Bootloader: U-Boot
* Kernel: in /boot on the system partition (device-specific?)
* Device tree: in /boot on the system partition (device-specific)
* System: standard Armbian, preferably on a BTRFS partition

## Steps

* download pre-compiled image
* build image
* resize image
* download Debian DVD
* add DVD contents to image

## Links

* https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html
* https://blog.oddbit.com/post/2016-02-08-a-systemd-nspawn-connection-dr/

