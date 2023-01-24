#!/bin/bash

if [ ! -d apt ]; then
	git clone --recurse-submodules --depth 1 https://salsa.debian.org/apt-team/apt.git
fi

cd apt
if [ ! -d build]; then mkdir build; fi
cd build
cmake ..
