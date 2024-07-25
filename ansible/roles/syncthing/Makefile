
SHELL = /bin/bash

HOST = localhost

TESTS = $(wildcard tasks/*/*_test.yml)


.PHONY: test $(TESTS)
test: $(TESTS)
$(TESTS):
	ansible-playbook -l $(HOST) ./$@

