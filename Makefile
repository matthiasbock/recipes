#
# Makefile to allow for simpler CI build jobs
#

include containers/make.mk


all: container container_image push

clean: delete_container
