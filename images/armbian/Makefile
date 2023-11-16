
SHELL=/bin/bash

TARGET=cubietruck
RELEASE=Bookworm_current

INPUT_IMAGE=$(RELEASE).img
SECTOR_SIZE=512
NUM_SECTORS_MBR=2048

MBR=$(FOLDER_UNPACKED)/bootsect.img
INPUT_IMAGE_BOOT=$(FOLDER_UNPACKED)/boot.img
INPUT_IMAGE_OS=$(FOLDER_UNPACKED)/system.img

FOLDER_UNPACKED=unpacked
FOLDER_BOOT=$(FOLDER_UNPACKED)/boot
FOLDER_OS=$(FOLDER_UNPACKED)/system

SIZE_OUTPUT_IMAGE=32*1024*1024*1024

OUTPUT_IMAGE_BOOT=$(FOLDER_UNPACKED)/boot2.img
SIZE_BOOT=500*1024*1024
OUTPUT_IMAGE_OS=$(FOLDER_UNPACKED)/system2.img
SIZE_OS=$(SIZE_OUTPUT_IMAGE)-$(SIZE_BOOT)-$(NUM_SECTORS_MBR)*$(SECTOR_SIZE)


all: $(IMAGE)


# Download pre-compiled image
$(INPUT_IMAGE):
	TARGET=$(TARGET) RELEASE=$(RELEASE) ./download.sh


# Unpack MBR and individual partitions from image
$(MBR) $(INPUT_IMAGE_BOOT) $(INPUT_IMAGE_OS): $(INPUT_IMAGE)
	IMAGE=$< \
	FILENAME_MBR=$(MBR) \
	FILENAME_BOOT=$(INPUT_IMAGE_BOOT) \
	FILENAME_OS=$(INPUT_IMAGE_OS) \
	./unpack_partitions.sh

$(FOLDER_BOOT): $(INPUT_IMAGE_BOOT)
	FILE=$< \
	FOLDER=$@ \
	./unpack_filesystem.sh
	@rm -vf $<

$(FOLDER_OS): $(INPUT_IMAGE_OS)
	FILE=$< \
	FOLDER=$@ \
	./unpack_filesystem.sh
	@rm -vf $<


# Create custom partition images
$(OUTPUT_IMAGE_BOOT): $(FOLDER_BOOT)
	FOLDER=$< \
	FILENAME=$@ \
	FSTYPE=ext4 \
	SIZE=$(shell echo $$(($(SIZE_BOOT)))) \
	./pack_filesystem.sh

$(OUTPUT_IMAGE_OS): $(FOLDER_OS)
	FOLDER=$< \
	FILENAME=$@ \
	FSTYPE=btrfs \
	MKFS_ARGS=subvolume=@rootfs,ssd \
	MOUNT_OPTIONS=dev,exec,autodefrag,subvolume=@rootfs,compress=zlib:9,ssd \
	SIZE=$(shell echo $$(($(SIZE_OS)))) \
	./pack_filesystem.sh


# Pack custom image
$(OUTPUT_IMAGE): $(OUTPUT_IMAGE_BOOT) $(OUTPUT_IMAGE_OS)
	IMAGE_SIZE=$(SIZE_OUTPUT_IMAGE) \
	SECTOR_SIZE=$(SECTOR_SIZE) \
	FILENAME_MBR=$(MBR) \
	FILENAME_BOOT=$(OUTPUT_IMAGE_BOOT) \
	FILENAME_OS=$(OUTPUT_IMAGE_OS) \
	FILENAME_IMAGE=$@ \
	./pack_partitions.sh


clean:
	@rm -vf \
		$(INPUT_IMAGE) \
		$(MBR) \
		$(INPUT_IMAGE_BOOT) \
		$(INPUT_IMAGE_OS) \
		$(OUTPUT_IMAGE)
	@rm -vfr \
		$(FOLDER_UNPACKED)
