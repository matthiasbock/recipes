
# Bootable system image for a HP Proliant DL360 Server, Gen 6 or 7

Constraints:

* 32GB micro SD card
* those machine (likely) don't support GPT partition tables, only DOS
* GRUB

## Derive from existing system

### Partitioning

* create two partitions on the SD card:
  * one for GRUB
  * one for Debian (possibly LUKS encrypted)

### Copy the existing system

* mount the root partition somewhere: `/media/mmc/root`
* mount the boot partition inside the root partition: `/media/mmc/root/boot`

### Install additional packages

* start the system in a container
* using the host wifi
* enabling access to the host's devices, including the SD card
* enabling device-mapper control from within the container (required by dmsetup)
* enabling filesystem-access via sysfs (required by update-initramfs)

~~~sh
$ systemd-nspawn \
--network-ipvlan wlan0 \
--property="DeviceAllow=/dev/mapper/control rwm" \
--bind-ro=/dev/{mapper,disk,mmcblk{0,0p1,0p2},dm-{0,1,2,3,4,5,6}} \
--bind-ro=/sys/fs/btrfs \
-D /media/mmc/root/
~~~

### Update partition IDs

* use `blkid` to get the UUIDs of the new partitions
* update `/etc/fstab` accordingly
* update `/etc/crypttab` to use the UUID of the new root partition

### Install GRUB

* set `GRUB_ENABLE_CRYPTODISK=y` in file `/etc/default/grub`
* make sure, `/dev/mmcblk0p1` is mounted to `/media/mmc/root/boot`

~~~sh
$ grub-install --target=i386-pc --boot-directory=/media/mmc/root/boot --recheck /dev/mmcblk0
~~~

### Verify booting

~~~sh
$ qemu-system-x86_64 -enable-kvm -m 2048 -drive file=/dev/mmcblk0,format=raw
~~~
