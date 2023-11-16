#!/bin/bash

url_sha_file="https://redirect.armbian.com/$TARGET/$RELEASE.sha"
url_signature_file="https://redirect.armbian.com/$TARGET/$RELEASE.asc"
url_image="https://redirect.armbian.com/$TARGET/$RELEASE"
image_filename="$RELEASE.img"


wget -c $url_sha_file
wget -c $url_signature_file
wget -c --progress=dot:mega -O $image_filename $url_image

sha1sum $image_filename
sha256sum $image_filename
sha512sum $image_filename
