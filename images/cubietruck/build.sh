#!/bin/bash
#
# https://sd-card-images.johang.se/boards/cubietruck.html
#

PWD="$(dirname "$(realpath "$0")")"

set -e
set -x

cd "$PWD/../sd-card-images.johang.se"

wget \
	-c \
	--progress=dot:mega \
	https://dl.sd-card-images.johang.se/boots/2024-06-01/boot-cubietruck.bin.gz \
	https://dl.sd-card-images.johang.se/debians/2024-06-03/debian-bullseye-armhf-hum9ei.bin.gz

cd "$PWD"

zcat \
	$(ls -1 boot-cubietruck*.bin.gz | head -n1) \
	$(ls -1 debian-*-armhf-*.bin.gz | head -n1) \
	> cubietruck.img

