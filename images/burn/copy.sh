#!/bin/bash

#
# Copies a folder to the destination,
# maintaining file properties and timestamps
# and making the target read-only
#
copy_to_image() {
    local SOURCE="$1"
    local DESTINATION="$2"

    [[ -d "$SOURCE" ]] || { echo "Source directory does not exist: '$SOURCE'" >&2; return 1; }
    [[ -d "$DESTINATION" ]] || { echo "Destination directory does not exist: '$DESTINATION'" >&2; return 1; }

    time rsync -i -rlptDAXUH --partial --inplace --sparse --progress --human-readable --timeout=20 --stats \
    "$SOURCE" "$DESTINATION"

    echo -n "Adjusting permissions ... "

    # The medium will be read-only, which shall be reflected by the mounted filesystem's permissions.
    # Also, all files shall be readable and all folders accessible by any user.
    sudo find "$DESTINATION" -type f -exec chmod a+r a-w {} \;
    sudo find "$DESTINATION" -type d -exec chmod a+rx a-w {} \;

    echo "done"
}


if [[ "$0" == "$BASH_SOURCE" ]]; then
    copy_to_image "$@"
fi

