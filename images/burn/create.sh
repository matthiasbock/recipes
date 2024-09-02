#!/bin/bash

#
# Creates an encrypted disk image and mounts it
#
create_and_mount() {
    set -e

    # Use the basename of $IMAGE_FILE as the LUKS name, without the filename extension; but replace uppercase letters with lowercase and spaces with underscores
    LUKS_NAME="$(basename "$IMAGE_FILE" .${IMAGE_FILE##*.} | tr '[:upper:]' '[:lower:]' | tr ' ' '_')"

    # Name of the temporary directory to mount
    MOUNTPOINT=/tmp/image-$(head -c 3 /dev/urandom | xxd -p)
    while [ -e "$MOUNTPOINT" ]; do
        sleep 1
        MOUNTPOINT=/tmp/image-$(head -c 3 /dev/urandom | xxd -p)
    done

    # Key filename
    IMAGE_FILE="$(realpath "$IMAGE_FILE")"
    KEY_FILE="$IMAGE_FILE.key"

    # Do not overwrite an existing key file
    [[ ! -e "$KEY_FILE" ]] || { echo "Key file '$KEY_FILE' already exists. Aborting." >&2; return 1; }

    # Create an empty image file
    echo -n "Creating image file '$IMAGE_FILE' with size $IMAGE_SIZE_MB MB ..." >&2
    [[ "$IMAGE_SIZE_MB" =~ ^[0-9]+$ ]] || { echo "Invalid image size '$IMAGE_SIZE_MB'. Aborting." >&2; return 1; }
    dd if=/dev/zero conv=sparse count=1 bs=1000 seek=$(( ( $IMAGE_SIZE_MB-1 ) * 1000 )) of="$IMAGE_FILE"
    echo "done" >&2

    # Make file accessible as loop device
    echo -n "Creating loop device ... " >&2
    LOOP_DEV=$(sudo losetup --show -f "$IMAGE_FILE" 2>/dev/null)
    echo "done: '$LOOP_DEV'" >&2
    [[ "$LOOP_DEV" =~ ^.*loop[0-9].*$ ]] || { echo "Error: Failed to create loop device. Aborting." >&2; return 1; }

    # Use random data from /dev/urandom to create a key file
    echo "Creating key file: '$KEY_FILE'" >&2
    dd if=/dev/urandom of="$KEY_FILE" bs=1024 count=4

    # Format as encrypted disk image
    echo "Formatting as LUKS partition: $LOOP_DEV" >&2
    sudo cryptsetup --batch-mode luksFormat "$LOOP_DEV" --key-file "$KEY_FILE"
    echo "Opening LUKS partition: $LOOP_DEV as $LUKS_NAME" >&2
    sudo cryptsetup --batch-mode luksOpen "$LOOP_DEV" "$LUKS_NAME" --key-file "$KEY_FILE"

    echo -n "Creating btrfs filesystem with label: '$BTRFS_LABEL' ... " >&2
    sudo mkfs.btrfs \
        -v -f \
        -d "$BTRFS_PROFILE_DATA" \
        -m "$BTRFS_PROFILE_METADATA" \
        --csum sha256 \
        -L "$BTRFS_LABEL" \
        "/dev/mapper/$LUKS_NAME"
    echo "done" >&2

    echo "Mounting: $LOOP_DEV on $MOUNTPOINT" >&2
    mkdir -p "$MOUNTPOINT"
    sudo mount \
        -o autodefrag,compress=zlib:9 \
        "/dev/mapper/$LUKS_NAME" "$MOUNTPOINT"

    echo "Adjusting permissions..." >&2
    sudo chown -R $USER:$USER "$MOUNTPOINT"
    echo "done" >&2

    echo "$MOUNTPOINT"
}


if [[ "$0" == "$BASH_SOURCE" ]]; then
    set -e

    IMAGE_FILE=dvd.iso
    IMAGE_SIZE_MB=4700

    BTRFS_LABEL="Backup DVD 18.08.2024"
    BTRFS_PROFILE_DATA=single
    BTRFS_PROFILE_METADATA=dup

    MOUNTPOINT=$(create_and_mount)

    source copy.sh

    WAIT=5
    echo "Copying begins in ${WAIT}s... press Ctrl+C to cancel"
    sleep $WAIT

    copy_to_image /path/to/data $MOUNTPOINT/
fi

