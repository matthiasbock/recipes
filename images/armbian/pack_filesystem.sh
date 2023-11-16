#!/bin/bash
#
# Creates an image with the specified filesystem and
# copies all files in the specified folder to it
#
# Required environment variables:
# FOLDER=
# FSTYPE=
# FILENAME=
# SIZE=
#
# Optional environment variables:
# MKFS_ARGS=
# MOUNT_OPTIONS=
#

set -e

LOOPDEV=/dev/loop4
MOUNT_POINT=/tmp/pack_filesystem.tmp

echo "Creating empty sparse image..."
dd if=/dev/null of=$FILENAME --sparse bs=1 seek=$SIZE

echo "Opening image as loopback device..."
losetup $LOOPDEV $FILENAME

echo "Creating filesystem..."
if [ "$MKFS_ARGS" == "" ]; then
  mkfs -t $FSTYPE $LOOPDEV
else
  mkfs -t $FSTYPE -o $MKFS_ARGS $LOOPDEV
fi

echo "Mounting the new filesystem..."
mkdir -p $MOUNT_POINT
if [ "$MOUNT_OPTIONS" == "" ]; then
  mount $LOOPDEV $MOUNT_POINT
else
  mount $LOOPDEV -o $MOUNT_OPTIONS $MOUNT_POINT
fi

echo "Copying files to new filesystem..."
rsync -ariHS --partial --inplace --devices --specials \
  $FOLDER/* \
  $MOUNT_POINT/

echo "Unmounting..."
sync
umount -f $MOUNT_POINT

echo "Closing loopback device..."
sync
losetup -d $LOOPDEV

echo "Successfully packed files and folders into a new image."
