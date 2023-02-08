#
# Makefile to allow for simpler CI build jobs
#

SHELL=/bin/bash

include containers/make.mk


all: container container_image push

clean: delete_container
