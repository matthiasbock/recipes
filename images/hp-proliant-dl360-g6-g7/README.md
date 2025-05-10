
# Bootable system image for a HP Proliant DL360 Server, Gen 6 or 7

Constraints:

* 32GB micro SD card
* those machine likely don't support GPT partition tables, only DOS
* GRUB

## Derive from existing system

* create two partitions on the SD card:
  * one for GRUB
  * one for Debian (LUKS encrypted)
* mount the root partition somewhere: `/media/mmc/root`
* mount the boot partition inside the root partition: `/media/mmc/root/boot`
* start the system in a container
  * use the host wifi
  * enable access to the host's devices, including the SD card
  * enable device-mapper control from within the container (required by dmsetup)
  * enable filesystem-access via sysfs (required by update-initramfs)

~~~sh
systemd-nspawn \
--network-ipvlan wlan0 \
--property="DeviceAllow=/dev/mapper/control rwm" \
--bind-ro=/dev/{mapper,disk,mmcblk{0,0p1,0p2},dm-{0,1,2,3,4,5,6}} \
--bind-ro=/sys/fs/btrfs \
-D /media/mmc/root/
~~~

* use `blkid` to get the UUIDs of the new partitions
* update `/etc/fstab` accordingly
* update `/etc/crypttab` to use the UUID of the new root partition

