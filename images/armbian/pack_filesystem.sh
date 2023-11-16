#!/bin/bash
#
# Arguments: FOLDER= FSTYPE= MKFS_ARGS= MOUNT_OPTIONS= FILENAME= SIZE=
#

LOOPDEV=/dev/loop4
MOUNT_POINT=/tmp/pack_filesystem.tmp

set -e

# Create empty image (sparse)
dd if=/dev/null of=$FILENAME --sparse bs=1 seek=$SIZE

# Open image as loopback device
losetup $LOOPDEV $FILENAME

# Create filesystem
if [ "$MKFS_ARGS" == "" ]; then
  mkfs -t $FSTYPE $LOOPDEV
else
  mkfs -t $FSTYPE -o $MKFS_ARGS $LOOPDEV
fi

# Mount the new filesystem
mkdir -p $MOUNT_POINT
if [ "$MOUNT_OPTIONS" == "" ]; then
  mount $LOOPDEV $MOUNT_POINT
else
  mount $LOOPDEV -o $MOUNT_OPTIONS $MOUNT_POINT
fi

# Copy all files
rsync -ariHS --partial --inplace --devices --specials \
  $FOLDER/* \
  $MOUNT_POINT/

# Unmount the new image
sync
umount -f $MOUNT_POINT

# Close loopback device
sync
losetup -d $LOOPDEV
