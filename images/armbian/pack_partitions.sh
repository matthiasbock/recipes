#!/bin/bash
#
# Packs the (DOS) partitions into a bootable image
#
# Required environment variables:
# * IMAGE_SIZE
# * SECTOR_SIZE
# * FILENAME_MBR
# * FILENAME_BOOT
# * SECTOR_OFFSET_BOOT
# * FILENAME_OS
# * SECTOR_OFFSET_OS
# * FILENAME_IMAGE
#

# Create empty (sparse) file
dd if=/dev/null of=$FILENAME_IMAGE bs=1 seek=$SIZE

echo "Copying master boot record..."
dd if=$FILENAME_MBR of=$FILENAME_IMAGE bs=$SECTOR_SIZE

echo "Copying boot partition..."
dd if=$FILENAME_BOOT of=$FILENAME_IMAGE bs=$SECTOR_SIZE seek=$SECTOR_OFFSET_OS

echo "Copying system partition..."
dd if=$FILENAME_OS of=$FILENAME_IMAGE bs=$SECTOR_SIZE seek=$SECTOR_OFFSET_OS
