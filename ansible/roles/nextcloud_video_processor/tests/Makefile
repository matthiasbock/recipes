
SHELL = /bin/bash

HOST = localhost

TESTS = $(wildcard *.yml)


.PHONY: tests $(TESTS)
tests: $(TESTS)
$(TESTS):
	ansible-playbook -l $(HOST) ./$@


# test_build_image:
# 	ansible-playbook -l $(HOST) ./build-image.yml


# test_remove_image:


# test_create_container:


# test_remove_container:


# test_start_container:


# test_stop_container:
