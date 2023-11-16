
SHELL=/bin/bash

TARGET=cubietruck
RELEASE=Bookworm_current

INPUT_IMAGE=$(RELEASE).img
FOLDER_UNPACKED=unpacked
MBR=$(FOLDER_UNPACKED)/bootsect.img
INPUT_IMAGE_BOOT=$(FOLDER_UNPACKED)/boot.img
INPUT_IMAGE_OS=$(FOLDER_UNPACKED)/system.img
FOLDER_BOOT=$(FOLDER_UNPACKED)/boot
FOLDER_OS=$(FOLDER_UNPACKED)/system


all: $(IMAGE)


# Download image
$(INPUT_IMAGE):
	TARGET=$(TARGET) RELEASE=$(RELEASE) ./download.sh


# Unpack partitions
$(MBR) $(INPUT_IMAGE_BOOT) $(INPUT_IMAGE_OS): $(INPUT_IMAGE)
	IMAGE=$< \
	FILENAME_MBR=$(MBR) \
	FILENAME_BOOT=$(INPUT_IMAGE_BOOT) \
	FILENAME_OS=$(INPUT_IMAGE_OS) \
	./unpack_partitions.sh

$(FOLDER_BOOT): $(INPUT_IMAGE_BOOT)
	FILE=$< FOLDER=$@ ./unpack_filesystem.sh
	@rm -vf $<

$(FOLDER_OS): $(INPUT_IMAGE_OS)
	FILE=$< FOLDER=$@ ./unpack_filesystem.sh
	@rm -vf $<


# Create custom partition images
$(OUTPUT_IMAGE_BOOT): $(FOLDER_BOOT)
	...

$(OUTPUT_IMAGE_OS): $(FOLDER_OS)
	...


# Pack custom image
$(OUTPUT_IMAGE): $(OUTPUT_IMAGE_BOOT) $(OUTPUT_IMAGE_OS)
	...


clean:
	@rm -vf \
		$(INPUT_IMAGE) \
		$(MBR) \
		$(INPUT_IMAGE_BOOT) \
		$(INPUT_IMAGE_OS) \
		$(OUTPUT_IMAGE)
	@rm -vfr \
		$(FOLDER_UNPACKED)
