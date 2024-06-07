
# BananaPi Lamobo R1

* SoC: Allwinner A20
* Bootloader: U-Boot
* Kernel: in /boot on the system partition (device-specific?)
* Device tree: in /boot on the system partition (device-specific)
* System: standard Armbian, preferably on a BTRFS partition

## Steps

~~~sh
# The image to be generated
IMG=lamobo_r1.img
IMG_SIZE=$((32*1000*1000))
IMG_SECTOR_SIZE=512

# Paths used during image generation
MNT=/mnt
MNT_DVD=/media/cdrom
APT_CACHE=/var/cache/apt
SOURCES_LIST=$MNT/etc/apt/sources.list.d/dvd.list
DIR_DVD=$MNT/var/lib/apt/dvd

# Files to download
URL_UBOOT=https://dl.sd-card-images.johang.se/boots/2024-06-01/boot-lamobo_r1.bin.gz
URL_DEBIAN=https://dl.sd-card-images.johang.se/debians/2024-06-03/debian-bookworm-armhf-zue4ye.bin.gz

URL_JIGDO=https://cdimage.debian.org/debian-cd/current/armhf/jigdo-dvd/debian-12.5.0-armhf-DVD-1.jigdo
URL_JIGDO_TEMPLATE=https://cdimage.debian.org/debian-cd/current/armhf/jigdo-dvd/debian-12.5.0-armhf-DVD-1.template

# Download pre-compiled images: https://sd-card-images.johang.se/boards/lamobo_r1.html
wget -c --progress=dot:mega $URL_UBOOT $URL_DEBIAN
IMG_UBOOT=$(basename $URL_UBOOT)
IMG_DEBIAN=$(basename $URL_DEBIAN)

# Create SD card image
zcat $IMG_UBOOT $IMG_DEBIAN > $IMG

# Download a Debian DVD image: https://get.debian.org/debian-cd/12.5.0/armhf/iso-dvd/
#wget -c --progress=dot:mega \
#    https://get.debian.org/debian-cd/12.5.0/armhf/iso-dvd/debian-12.5.0-armhf-DVD-1.iso

# Download Jigdo recipe and temple: https://cdimage.debian.org/debian-cd/current/armhf/jigdo-cd/
JIGDO=$(basename $URL_JIGDO_RECIPE)
JIGDO_GZ=$JIGDO.gz
wget -c --progress=dot -O $JIGDO_GZ $URL_JIGDO
wget -c --progress=dot $URL_JIGDO_TEMPLATE
gz -d $JIGDO_GZ

# Compose DVD image using jigdo
jigdo-lite \
    --scan $MNT_DVD \
    --scan $APT_CACHE \
    $JIGDO

# Extract DVD image filename from jigdo recipe
IMG_DVD="$(realpath "$(grep ^Filename $JIGDO | cut -d'=' -f2)")"

# Enlarge SD card image and system partition to desired size (at least plus the size of the DVD image)
IMG_NUM_SECTORS=$(($IMG_SIZE / $IMG_SECTOR_SIZE))
IMG_LAST_SECTOR=$(($IMG_NUM_SECTORS - 1))
dd sparse=conv if=/dev/null of=$IMG bs=$IMG_SECTOR_SIZE seek=$IMG_LAST_SECTOR count=1
# TODO... sfdisk...

# Mount SD card image
mount -o loop $IMG $MNT
LOOP=$(losetup --find --show "$(realpath $IMG)")
partprobe -s $LOOP

# Mount DVD image
mount -o ro,loop $IMG_DVD $MNT_DVD

# Copy DVD contents to mounted partition
mkdir -p $DIR_DVD
cp -avr $MNT_DVD/* $DIR_DVD/

# Unmount DVD image
umount -fld $MNT_DVD

# Configure copied DVD contents as apt package source in /etc/apt/sources.list.d/cdrom.list
mkdir -p "$(dirname "$SOURCES_LIST")"
touch "$SOURCES_LIST"
# TODO: echo ... > "$SOURCES_LIST"

# Boot the new system in a virtualized container
cp -av "$(which qemu-arm-static)" $MNT/
systemd-nspawn -D $MNT qemu-arm-static /bin/init
~~~

Within the virtualized container:

~~~sh
# Install additional software
apt update
apt install -y apt aptitude apt-transport-https ca-certificates
apt install -y bash bash-completion vim nano mc rsync wget curl
apt dist-upgrade -y
~~~

## Links

* https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html
* https://blog.oddbit.com/post/2016-02-08-a-systemd-nspawn-connection-dr/

