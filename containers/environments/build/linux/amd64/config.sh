
package-bundles:
  - version-control.list
  - build-tools.list
  - compiler/amd64.list

apt-get -q build-dep -y linux-image-amd64
apt-get -q remove -y linux-image-* linux-headers-*

git reset --hard HEAD
git checkout v5.12

ARCH=arm make omap2plus_defconfig
ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make bzImage
ARCH=arm CROSS_COMPILE=/usr/lib/ccache/arm-linux-gnueabihf- make -j3 bzImage modules

Warum funktioniert ccache nicht?
Es werden Objekte im ccache Volume abgelegt, aber die vorhandenen nicht genutzt (cache hit: 0)
