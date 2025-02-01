
DIR_LAMOBO_IMAGE ?= $(dir $(lastword $(MAKEFILES_LIST)))
LAMOBO_IMAGE ?= $(DIR_LAMOBO_IMAGE)/lamobo_r1.img
LAMOBO_PLAYBOOK ?=  $(DIR_LAMOBO_IMAGE)/lamobo-image.yml


$(LAMOBO_IMAGE): Makefile $(wildcard *.mk)
	@echo "Combining U-Boot and Debian partitions into a bootable image"


.PHONY: clean-lamobo-image
clean-lamobo-image:
	@cd $(DIR_LAMOBO_IMAGE) && \
	rm -vf \
		boot-lamobo*.bin.gz \
		debian-*-*-*.bin.gz \
		*-index.json \
		lamobo*.img

