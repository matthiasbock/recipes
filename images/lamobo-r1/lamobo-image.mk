

DIR_LAMOBO_IMAGE = $(dir $(lastword $(MAKEFILES_LIST)))


.PHONY: lamobo-image
lamobo-image:
	ansible-playbook -v $(DIR_LAMOBO_IMAGE)/lamobo-image.yml


.PHONY: clean-lamobo-image
clean-lamobo-image:
	@cd $(DIR_LAMOBO_IMAGE) && \
	rm -vf \
		boot-lamobo*.bin.gz \
		debian-*-*-*.bin.gz \
		*-index.json \
		lamobo*.img

