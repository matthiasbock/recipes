
SHELL=/bin/bash

DIR_VENV=.venv

NFTABLES_FAILSAFE=nftables-failsafe.yml
COCKPIT=cockpit.yml
#PLAYBOOKS=$(filter-out $(INVENTORY),$(wildcard *.yml))
PLAYBOOKS=$(NFTABLES_FAILSAFE) $(COCKPIT)


$(info $(PLAYBOOKS))

.PHONY: all
all: list_hosts


.PHONY: check
check:
	ansible-playbook \
		-i $(INVENTORY) \
		$(PLAYBOOKS) \
		--syntax-check


.PHONY: list_hosts
list_hosts:
	ansible-playbook \
		-i $(INVENTORY) \
		$(PLAYBOOKS) \
		--list-hosts


.PHONY: $(NFTABLES_FAILSAFE)
$(NFTABLES_FAILSAFE):
	ansible-playbook \
		-i $(INVENTORY) \
		$(NFTABLES_FAILSAFE) \
		--tags deploy


.PHONY: role
role:
	if [ "$$ROLE_NAME" != "" ]; then \
		mkdir -v roles/$$ROLE_NAME/{defaults,tasks,templates} || true; \
		touch roles/$$ROLE_NAME/{defaults,tasks,templates}/main.yml || true; \
	fi


.PHONY: venv
venv: $(DIR_VENV)
$(DIR_VENV): requirements.txt
	[[ -d "$(DIR_VENV)" ]] || python3 -m venv $(DIR_VENV)
	source $(DIR_VENV)/bin/activate && \
	pip3 install -r requirements.txt
	@touch --no-create "$@"


.PHONY: test
test: $(DIR_VENV)
	source "$(DIR_VENV)/bin/activate" && \
	pytest \
		-v \
		filters/jigdo/extract_url_test.py
	ansible-playbook filters/jigdo/extract_url_test.yml

