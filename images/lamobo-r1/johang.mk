
JOHANG_LAMOBO_INFO_URL = https://sd-card-images.johang.se/boards/lamobo_r1.html

JOHANG_IMAGE ?= lamobo_r1.img

JOHANG_OS ?= debian
JOHANG_DISTRO ?= bookworm
JOHANG_ARCH ?= armhf
JOHANG_DTBS ?= sun7i-a20-lamobo-r1

# Downloading from dl.sd-card-images.johang.se requires a user-agent
JOHANG_USER_AGENT ?= Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36

JOHANG_DEBIAN_INDEX_URL ?= https://cdn.sd-card-images.johang.se/index-debians-$(JOHANG_ARCH).js
JOHANG_DEBIAN_INDEX ?= johang-debian-$(JOHANG_ARCH).json
# JOHANG_DEBIAN_URL = https://dl.sd-card-images.johang.se/debians/2024-06-03/debian-bookworm-armhf-zue4ye.bin.gz
# FIXME: No longer available (outdated); parse from index file instead
JOHANG_DEBIAN_URL ?= johang-debian-$(JOHANG_ARCH).txt
JOHANG_DEBIAN_IMAGE ?= johang-debian-$(JOHANG_ARCH).img

JOHANG_UBOOT_INDEX_URL ?= https://cdn.sd-card-images.johang.se/index-boots.js
JOHANG_UBOOT_INDEX ?= johang-uboot.json
# JOHANG_UBOOT_URL ?= https://dl.sd-card-images.johang.se/boots/2024-06-01/boot-lamobo_r1.bin.gz
# FIXME: No longer available (outdated); parse from index file instead
JOHANG_UBOOT_URL ?= johang-uboot-$(JOHANG_ARCH).txt
JOHANG_UBOOT_IMAGE ?= johang-uboot-$(JOHANG_ARCH).img


.SECONDARY: \
	$(JOHANG_DEBIAN_INDEX) \
	$(JOHANG_DEBIAN_URL) \
	$(JOHANG_DEBIAN_IMAGE) \
	$(JOHANG_UBOOT_INDEX) \
	$(JOHANG_UBOOT_URL) \
	$(JOHANG_UBOOT_IMAGE) \
	$(JOHANG_IMAGE)


.PHONY: johang-index
johang-index: johang-debian-index johang-uboot-index


.PHONY: johang-debian-index
johang-debian-index: $(JOHANG_DEBIAN_INDEX)
$(JOHANG_DEBIAN_INDEX):
	@wget \
		-U "$(JOHANG_USER_AGENT)" \
		-c \
		--progress=dot:kilo \
		-O - \
		"$(JOHANG_DEBIAN_INDEX_URL)" | \
	head -n-1 | \
	tail -n+2 | \
	jq > $@


.PHONY: johang-debian-url
johang-debian-url: $(JOHANG_DEBIAN_URL)
$(JOHANG_DEBIAN_URL): $(JOHANG_DEBIAN_INDEX)
	@echo -n "https://dl.sd-card-images.johang.se" > $@
	@jq -r \
		'.[] | select(.os == "$(JOHANG_OS)") | select(.dist == "$(JOHANG_DISTRO)") | select(.arch == "$(JOHANG_ARCH)") | select(.dtbs[] | contains("$(JOHANG_DTBS)")) | "\(.build) \(.path) \(.password)"' \
		"$(JOHANG_DEBIAN_INDEX)" | \
	sort -r | \
	head -n1 | \
	awk '{print substr($$0,12,length($$0)-12-6)}' \
	>> "$@"


.PHONY: johang-debian-image
johang-debian-image: $(JOHANG_DEBIAN_IMAGE)
$(JOHANG_DEBIAN_IMAGE).gz: $(JOHANG_DEBIAN_URL)
	@URL="$$(cat "$^")" && \
	FILENAME="$$(basename $$URL)" && \
	wget \
		-U "$(JOHANG_USER_AGENT)" \
		-c \
		--progress=dot:mega \
		-O "$$FILENAME" \
		"$$URL" && \
	cp -av "$$FILENAME" "$@"

$(JOHANG_DEBIAN_IMAGE): $(JOHANG_DEBIAN_IMAGE).gz
	gzip -d "$<"


.PHONY: johang-uboot-index
johang-uboot-index: $(JOHANG_UBOOT_INDEX)
$(JOHANG_UBOOT_INDEX):
	@wget \
		-U "$(JOHANG_USER_AGENT)" \
		-c \
		--progress=dot:kilo \
		-O - \
		"$(JOHANG_UBOOT_INDEX_URL)" | \
	head -n-1 | \
	tail -n+2 | \
	jq > $@


.PHONY: johang-uboot-url
johang-uboot-url: $(JOHANG_UBOOT_URL)
$(JOHANG_UBOOT_URL): $(JOHANG_UBOOT_INDEX)
	@echo -n "https://dl.sd-card-images.johang.se" > "$@"
	@jq -r \
		'.[] | select(.board == "lamobo_r1") | .path' \
		"$<" >> "$@" || rm "$@"


.PHONY: johang-uboot-image
johang-uboot-image: $(JOHANG_UBOOT_IMAGE)
$(JOHANG_UBOOT_IMAGE).gz: $(JOHANG_UBOOT_URL)
	@wget \
		-U "$(JOHANG_USER_AGENT)" \
		-c \
		--progress=dot:mega \
		-O "$@" \
		"$$(cat "$(JOHANG_UBOOT_URL)")" \

$(JOHANG_UBOOT_IMAGE): $(JOHANG_UBOOT_IMAGE).gz
	gzip -d "$<"


.PHONY: johang-image
johang-image: $(JOHANG_IMAGE)
$(JOHANG_IMAGE): $(JOHANG_UBOOT_IMAGE).gz $(JOHANG_DEBIAN_IMAGE).gz
	zcat $^ > $@

