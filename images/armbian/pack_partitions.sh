#!/bin/bash
#
# Packs the partitions into a bootable image
#
# Required environment variables:
# * IMAGE_SIZE
# * SECTOR_SIZE
# * FILENAME_MBR
# * FILENAME_BOOT
# * FILENAME_OS
# * FILENAME_IMAGE
#

set -e

echo "Packing partitions into image..."

SIZE_MBR=$(wc -c <"$FILENAME_MBR")
SIZE_BOOT=$(wc -c <"$FILENAME_BOOT")
SIZE_OS=$(wc -c <"$FILENAME_OS")

SECTORS_MBR=$(($SIZE_MBR/$SECTOR_SIZE))
SECTORS_BOOT=$(($SIZE_BOOT/$SECTOR_SIZE))
SECTORS_OS=$(($SIZE_OS/$SECTOR_SIZE))

SECTOR_OFFSET_BOOT=$SECTORS_MBR
SECTOR_OFFSET_OS=$(($SECTORS_MBR+$SECTORS_BOOT))

echo "Creating empty (sparse) file..."
dd if=/dev/null of=$FILENAME_IMAGE bs=1 seek=$IMAGESIZE

echo "Installing bootloader..."
dd if=$FILENAME_MBR of=$FILENAME_IMAGE bs=$SECTOR_SIZE

echo "Updating partition table..."
# TODO: use fdisk, cfdisk or gpart for automated partition table update

echo "Copying boot partition..."
dd if=$FILENAME_BOOT of=$FILENAME_IMAGE bs=$SECTOR_SIZE seek=$SECTOR_OFFSET_BOOT

echo "Copying system partition..."
dd if=$FILENAME_OS of=$FILENAME_IMAGE bs=$SECTOR_SIZE seek=$SECTOR_OFFSET_OS

echo "Done creating bootable image."
