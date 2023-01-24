#!/bin/bash

debian-base
apt build-dep apt
apt install triehash
apt clean
cp run.sh

