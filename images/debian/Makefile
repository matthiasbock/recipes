
#
# Download Debian images using Jigdo
# https://cdimage.debian.org/debian-cd/current/armhf/jigdo-cd/
#

SHELL = /bin/bash

# New image
URL_JIGDO = https://cdimage.debian.org/debian-cd/current/armhf/jigdo-dvd/debian-12.5.0-armhf-DVD-1.jigdo
URL_JIGDO_TEMPLATE = $(URL_JIGDO:.jigdo=.template)

JIGDO = $(shell basename $(URL_JIGDO))
JIGDO_GZ = $(JIGDO).gz
JIGDO_TEMPLATE = $(shell basename $(URL_JIGDO_TEMPLATE))
JIGDO_LIST = $(JIGDO:.jigdo=.iso.list)

IMAGE = $(JIGDO:.jigdo=.iso)

# Existing images
FILES_ISO = $(shell find ../.. -maxdepth 5 -type f -iname '*.iso')

# Path to more Debian packages
APT_CACHE = "/var/lib/apt"


all: $(IMAGE)


.PHONY: mount
mount:
	# Mounting ISO images: $(FILES_ISO)
	@for ISO in $(FILES_ISO); do \
		DIR=$$(basename $$ISO).mount; \
		mkdir -p $$DIR; \
		if [ "$(mount | fgrep "$$ISO")" != "" ]; then sudo umount -fd $$DIR; fi; \
		sudo mount -o ro,loop,user $$ISO $$DIR; \
	done


.PHONY: umount
umount:
	# Unmounting ISO images: $(FILES_ISO)
	for ISO in $(FILES_ISO); do \
		DIR=$$(basename $$ISO).mount; \
		if [ "$(mount | fgrep "$$DIR")" != "" ]; then sudo umount -fld $$DIR; fi; \
		if [ -d "$$DIR" ]; then sleep 0.5; rmdir $$DIR; fi; \
	done


$(IMAGE): $(JIGDO) $(JIGDO_TEMPLATE)
	make mount

	# Building new image
	jigdo-lite \
		--scan /var/lib/apt \
		--scan /var/cache/apt \
		--scan . \
		--noask \
		$(JIGDO)
	@touch --no-create "$@"

	make umount


$(JIGDO): $(JIGDO_GZ)
	# Unpacking jigdo recipe
	gzip -d $<


$(JIGDO_GZ):
	# Downloading jigdo recipe
	wget -c --progress=dot:mega -O $(JIGDO_GZ) $(URL_JIGDO)


$(JIGDO_TEMPLATE):
	# Downloading jigdo template
	wget -c --progress=dot:mega $(URL_JIGDO_TEMPLATE)


.PHONY: clean
clean: umount
	@rm -vf \
		$(JIGDO) \
		$(JIGDO_GZ) \
		$(JIGDO_TEMPLATE) \
		$(JIGDO_LIST) \
		$(IMAGE)

