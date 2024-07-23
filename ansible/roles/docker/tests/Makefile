
SHELL = /bin/bash

HOST = localhost

TESTS = $(wildcard */*.yml)


.PHONY: tests $(TESTS)
tests: $(TESTS)
$(TESTS):
	ansible-playbook -v -l $(HOST) ./$@

