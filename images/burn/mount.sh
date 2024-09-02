#!/bin/bash

#
# Mounts an encrypted disk image given image file path and key
#
mount() {
    set -e

    IMAGE_FILE="$1"
    KEY_FILE="$2"

    # TODO: Derive device name from filename or randomly
    LUKS_NAME="image"

    MOUNTPOINT="$3"

    # Create temporary directory as mount point
    if [ "$MOUNTPOINT" == "" ]; then
        MOUNTPOINT=/tmp/image-$(head -c 3 /dev/urandom | xxd -p)
        while [ -e "$MOUNTPOINT" ]; do
            sleep 1
            MOUNTPOINT=/tmp/image-$(head -c 3 /dev/urandom | xxd -p)
        done
    fi

    # Make file accessible as loop device
    echo -n "Creating loop device ... " >&2
    LOOP_DEV=$(sudo losetup --show -f "$IMAGE_FILE" 2>/dev/null)
    echo "done: '$LOOP_DEV'" >&2
    [[ "$LOOP_DEV" =~ ^.*loop[0-9].*$ ]] || { echo "Error: Failed to create loop device. Aborting." >&2; return 1; }

    # Open LUKS device
    echo "Opening LUKS partition: $LOOP_DEV as $LUKS_NAME" >&2
    sudo cryptsetup --batch-mode luksOpen "$LOOP_DEV" "$LUKS_NAME" --key-file "$KEY_FILE"

    # Mount LUKS device
    echo "Mounting: $LOOP_DEV on $MOUNTPOINT" >&2
    mkdir -p "$MOUNTPOINT"
    sudo mount \
        -o autodefrag,compress=zlib:9 \
        "/dev/mapper/$LUKS_NAME" "$MOUNTPOINT"

    echo "$MOUNTPOINT"
}


if [[ "$0" == "$BASH_SOURCE" ]]; then
    mount "$@"
fi

