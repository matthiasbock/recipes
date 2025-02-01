
# Official Debian DVD, downloaded/built using Jigdo
JIGDO_DEBIAN_VERSION ?= 12.9.0
JIGDO_DEBIAN_ARCH ?= armhf
JIGDO_BASE_URL ?= https://cdimage.debian.org/debian-cd/current/$(JIGDO_DEBIAN_ARCH)/jigdo-dvd
JIGDO_INDEX_URL ?= $(JIGDO_BASE_URL)/index.html

JIGDO_RECIPE_URL ?= $(JIGDO_BASE_URL)/debian-$(JIGDO_DEBIAN_VERSION)-$(JIGDO_DEBIAN_ARCH)-DVD-1.jigdo
JIGDO_RECIPE ?= $(notdir $(JIGDO_RECIPE_URL))

$(info Jigdo recipe file: $(JIGDO_RECIPE))

JIGDO_TEMPLATE_URL ?= $(JIGDO_BASE_URL)/debian-$(JIGDO_DEBIAN_VERSION)-$(JIGDO_DEBIAN_ARCH)-DVD-1.template
JIGDO_TEMPLATE ?= $(notdir $(JIGDO_TEMPLATE_URL))

$(info Jigdo template file: $(JIGDO_TEMPLATE))

DEBIAN_SOURCES ?= $(shell \
	grep -hR '^deb http' /etc/apt/sources.list* | \
	sed -E -e 's|deb http|http|g' | \
	cut -d' ' -f1 | \
	sort -u \
)
DEBIAN_SOURCE ?= https://mirror.23m.com/debian
APT_CACHE ?= /var/cache/apt/archives
DTB_CACHE ?= /var/cache/dtb
UBOOT_CACHE ?= /var/cache/uboot

JIGDO_USER_AGENT ?= Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36
# The local package cache to include when Jigdo builds the DVD image
JIGDO_IMAGE ?= debian-$(JIGDO_DEBIAN_VERSION)-$(JIGDO_DEBIAN_ARCH)-DVD-1.iso

$(info Jigdo image file: $(JIGDO_IMAGE))

MOUNTPOINT_JIGDO_IMAGE ?= /media/cdrom
MOUNTPOINT_LAMOBO_IMAGE ?= /mnt
DIR_DVD ?= $(MOUNTPOINT_LAMOBO_IMAGE)/var/lib/apt/dvd
SOURCES_LIST ?= $(MOUNTPOINT_LAMOBO_IMAGE)/etc/apt/sources.list.d/dvd.list


.SECONDARY: \
	$(JIGDO_RECIPE) \
	$(JIGDO_TEMPLATE) \
	$(JIGDO_IMAGE)


.PHONY: jigdo-recipe
jigdo-recipe: $(JIGDO_RECIPE)
$(JIGDO_RECIPE):
	wget \
		-U "$(JIGDO_USER_AGENT)" \
		-c \
		--progress=dot:kilo \
		-O "$@.gz" \
		$(JIGDO_RECIPE_URL)
	gunzip -f "$@.gz"
	# for SOURCE in $(DEBIAN_SOURCE) $(DEBIAN_SOURCES) do; \
	# 	echo "Debian=$$SOURCE" >> "$@"; \
	# done


.PHONY: jigdo-template
jigdo-template: $(JIGDO_TEMPLATE)
$(JIGDO_TEMPLATE):
	wget \
		-U "$(JIGDO_USER_AGENT)" \
		-c \
		--progress=dot:mega \
		-O "$@" \
		$(JIGDO_TEMPLATE_URL)


.PHONY: jigdo-dtb
jigdo-dtb: $(JIGDO_RECIPE)
	@sudo mkdir -p $(DTB_CACHE)
	@sudo chmod ugo+rw $(DTB_CACHE)
	grep -Eh '=Debian:.*\.dtb$$' "$(JIGDO_RECIPE)" | \
	sort -u | \
	cut -d: -f2 | \
	sed "s|^|$(DEBIAN_SOURCE)/|" | \
	xargs -n100 \
	wget \
		-U "$(JIGDO_USER_AGENT)" \
		-c \
		--progress=dot:mega \
		-P "$(DTB_CACHE)"


.PHONY: jigdo-uboot
jigdo-uboot: $(JIGDO_RECIPE)
	@sudo mkdir -p $(UBOOT_CACHE)
	@sudo chmod ugo+rw $(UBOOT_CACHE)
	grep -Eh '=Debian:.*(\.scr$$|images\/u\-boot\/|u\-boot*\.(bin|img)\.gz)' "$(JIGDO_RECIPE)" | \
	sort -u | \
	cut -d: -f2 | \
	sed "s|^|$(DEBIAN_SOURCE)/|" | \
	xargs -n100 \
	wget \
		-U "$(JIGDO_USER_AGENT)" \
		-c \
		--progress=dot:mega \
		-P "$(UBOOT_CACHE)"


.PHONY: jigdo-deb
jigdo-deb: $(JIGDO_RECIPE)
	@sudo mkdir -p $(APT_CACHE)
	@sudo chmod ugo+rw $(APT_CACHE)
	grep -Eh '=Debian:.*\.(deb|udeb)$$' "$(JIGDO_RECIPE)" | \
	cut -d: -f2 | \
	sed "s|^|$(DEBIAN_SOURCE)/|" | \
	xargs -n100 \
	wget \
		-U "$(JIGDO_USER_AGENT)" \
		-c \
		--progress=dot:mega \
		-P "$(APT_CACHE)"


.PHONY: jigdo-files
jigdo-files: jigdo-dtb jigdo-uboot jigdo-deb
	fgrep -h '=Debian:' "$(JIGDO_RECIPE)" | \
	grep -Ehv '.*\.deb$$' | \
	grep -Ehv '.*\.udeb$$' | \
	grep -Ehv '.*\.dtb$$' | \
	grep -Ehv '.*\.scr$$' | \
	sort -u | \
	cut -d: -f2 | \
	sed "s|^|$(DEBIAN_SOURCE)/|" | \
	xargs -n100 \
	wget \
		-U "$(JIGDO_USER_AGENT)" \
		-c \
		--progress=dot:mega


.PHONY: jigdo-image
jigdo-image: $(JIGDO_IMAGE)
$(JIGDO_IMAGE): $(JIGDO_RECIPE) $(JIGDO_TEMPLATE)
	FILENAME=$$(grep ^Filename $(JIGDO_RECIPE) | cut -d'=' -f2) && \
	echo "Creating image: $${FILENAME}" && \
	jigdo-lite \
		--scan . \
		--scan $(MOUNTPOINT_JIGDO_IMAGE) \
		--scan $(APT_CACHE) \
		--scan $(DTB_CACHE) \
		--scan /usr \
		--scan /var \
		$< && \
	cp -av $$FILENAME $@

