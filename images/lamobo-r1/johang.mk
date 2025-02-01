
JOHANG_IMAGE ?= lamobo_r1.img

JOHANG_OS ?= debian
JOHANG_DISTRO ?= bookworm
JOHANG_ARCH ?= armhf
JOHANG_DTBS ?= sun7i-a20-lamobo-r1

# Downloading from dl.sd-card-images.johang.se requires a user-agent
JOHANG_USER_AGENT ?= Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36

JOHANG_UBOOT_URL ?= https://dl.sd-card-images.johang.se/boots/2024-06-01/boot-lamobo_r1.bin.gz
JOHANG_UBOOT_IMAGE ?= johang-uboot.img

# JOHANG_OS_URL = https://dl.sd-card-images.johang.se/debians/2024-06-03/debian-bookworm-armhf-zue4ye.bin.gz
# FIXME: No longer available (outdated); parse from index file instead
JOHANG_OS_IMAGE ?= johang-debian.img

JOHANG_LAMOBO_INFO_URL = https://sd-card-images.johang.se/boards/lamobo_r1.html
JOHANG_INDEX_URL ?= https://cdn.sd-card-images.johang.se/index-debians-armhf.js
JOHANG_INDEX ?= johang.json
JOHANG_OS_INFO ?= johang-debian.json


.SECONDARY: \
	$(JOHANG_INDEX) \
	$(JOHANG_OS_INFO) \
	$(JOHANG_UBOOT_IMAGE_GZ) \
	$(JOHANG_UBOOT_IMAGE) \
	$(JOHANG_OS_IMAGE_GZ) \
	$(JOHANG_OS_IMAGE) \
	$(JOHANG_IMAGE)


.PHONY: johang-index
johang-index: $(JIGDO_INDEX)
$(JOHANG_INDEX):
	curl -s -o - $(JOHANG_INDEX_URL) | \
	tail -n+2 | \
	head -n-1 | \
	jq > $@


.PHONY: johang-os-info
johang-os-info: $(JOHANG_OS_INFO)
$(JOHANG_OS_INFO): $(JOHANG_INDEX)
	echo -n "https://dl.sd-card-images.johang.se" > $@
	jq -r \
		'.[] | select(.os == "$(JOHANG_OS)") | select(.dist == "$(JOHANG_DISTRO)") | select(.arch == "$(JOHANG_ARCH)") | select(.dtbs[] | contains("$(JOHANG_DTBS)")) | "\(.build) \(.path) \(.password)"' \
		$(JOHANG_INDEX) | \
	sort -r | \
	head -n1 | \
	awk '{print substr($$0,12,length($$0)-12-6)}' \
	>> "$@"


$(JOHANG_OS_IMAGE): $(JOHANG_OS_INFO)
	OS_URL="$$(cat $^)" && \
	OS_FILENAME="$$(basename $$OS_URL)" && \
	wget \
		-U "$(JOHANG_USER_AGENT)" \
		-c \
		--progress=dot:mega \
		-O "$$OS_FILENAME" \
		"$$OS_URL"


$(JOHANG_UBOOT_IMAGE): #$(JOHANG_INDEX)
	wget \
		-U "$(JOHANG_USER_AGENT)" \
		-c \
		--progress=dot:mega \
		-O "$@.gz" \
		"$(JOHANG_UBOOT_URL)"
	&& \
	gzip -d "$@"


.PHONY: johang-uboot-image
johang-uboot-image: $(JOHANG_UBOOT_IMAGE)

.PHONY: johang-os-image
johang-os-image: $(JOHANG_OS_IMAGE)

johang-%.img: johang-%.img.gz
	zcat $< > $@


.PHONY: johang-image
johang-image: $(JOHANG_IMAGE)
$(JOHANG_IMAGE): $(JOHANG_UBOOT_IMAGE) $(JOHANG_OS_IMAGE)
	zcat $^ > $@

