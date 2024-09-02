#!/bin/bash

#
# Fully unmounts a device
# including loopback devices and
# any wrapping LUKS layer
#
unmount()
{
    usage() {
        echo "Usage:"
        echo "  $0 <image_filename>"
        echo "  $0 <loopback_device>"
        echo "  $0 <mountpoint>"
        echo "  $0 <luks_device_name>"
        echo "  $0 <luks_device_path>"
        # echo "  $0 <logical_volume_name>"
        # echo "  $0 <volume_group_name>"
        # echo "  $0 <physical_volume_name>"
    }

    local ARG="$1"
    [[ "$ARG" != "" ]] || { echo "Argument missing. Aborting."; usage; exit 1; }

    sync

    local IMAGE_FILE=""
    local LOOP_DEV=""
    local MOUNTPOINT=""
    local LUKS_NAME=""
    local LUKS_DEV=""

    # TODO: Add support for logical volumes

    # If ARG begins with loop followed by a number, it is a loopback device
    if [[ "$ARG" =~ ^loop[0-9]+$ ]]; then
        echo "Argument is a loopback device name"
        LOOP_DEV="/dev/$ARG"
    else
        if [[ "$ARG" == *"/"* ]]; then
            if [[ "$ARG" == /dev/* ]]; then
                # If ARG begins with /dev/mapper/, it is a LUKS device path
                if [[ "$ARG" == /dev/mapper/* ]]; then
                    echo "Argument is a LUKS device path"
                    LUKS_DEV="$ARG"
                    LUKS_NAME="${ARG##/dev/mapper/}"
                    MOUNTPOINT="$(grep "^$ARG" /proc/mounts | awk '{print $3}')"
                else
                    # If ARG begins with /dev/loop, it is a loopback device
                    if [[ "$ARG" == /dev/loop* ]]; then
                        echo "Argument is a loopback device path"
                        LOOP_DEV="$ARG"
                        MOUNTPOINT="$(grep "^$ARG" /proc/mounts | awk '{print $3}')"
                    fi
                fi
            else
                # If ARG contains /, but does not begin with /dev, it is a mount point
                echo "Argument is a mount point"
                MOUNTPOINT="$ARG"
                LUKS_NAME="$(grep "^$ARG" /proc/mounts | awk '{print $1}' | sed 's/\/dev\/mapper\///')"
            fi
        else
            # if [ -d "$ARG" ]; then
            #     echo "Argument is the name of a folder
            # fi
            # If ARG contains no /, it is considered a LUKS device name
            echo "Argument is a LUKS device name"
            LUKS_NAME="$ARG"

            # In case the LUKS device is mounted, it shall be unmounted before closing
            MOUNTPOINT="$(grep "^/dev/mapper/$ARG" /proc/mounts | awk '{print $2}')"

            # In case the LUKS device wraps a loopback device, the latter shall also be closed afterwards
            # TODO: Get the loopback device, which is wrapped by the LUKS layer
        fi
    fi

    # echo "Adjusting permissions for read-only medium..."
    # sudo chmod -R ugo-w "$MOUNTPOINT"

    if [ "$MOUNTPOINT" != "" ]; then
        [[ -d "$MOUNTPOINT" ]] || { echo "Error: Mount point not found: '$MOUNTPOINT'"; exit 1; }
        echo "Unmounting folder: '$MOUNTPOINT'"
        sudo umount -fd "$MOUNTPOINT"
        sudo rmdir -p "$MOUNTPOINT"
    fi

    if [ "$LUKS_NAME" != "" ]; then
        LUKS_DEV="/dev/mapper/$LUKS_NAME"
    fi

    if [ "$LUKS_DEV" != "" ]; then
        echo "Closing LUKS device: '$LUKS_NAME'"
        sudo cryptsetup luksClose "$LUKS_NAME"
    fi

    if [ "$LOOP_DEV" != "" ]; then
        echo "Closing loopback device: '$LOOP_DEV'"
        [[ "$(losetup -a | grep "$LOOP_DEV")" != "" ]] && \
        sudo losetup -d "$LOOP_DEV"
    fi

    echo "Done."
}


if [[ "$0" == "$BASH_SOURCE" ]]; then
    unmount "$@"
fi

