

DOVECOT_CONTAINER=dovecot
POSTFIX_CONTAINER=postfix

POSTCONF=docker container exec -it $(POSTFIX_CONTAINER) postconf


.PHONY: up
up: \
		/etc/dovecot/dovecot.conf \
		/etc/dovecot/users.conf \
		/etc/postfix/main.cf
	docker-compose up -d --build


.PHONY: down
down:
	docker-compose down


/etc/dovecot:
	@sudo mkdir -p $@

/etc/dovecot/dovecot.conf: /etc/dovecot
	# sudo bash -c "docker run -it --rm docker.io/mailcow/dovecot:2.4 cat /etc/dovecot/dovecot.conf > $@"
	@sudo touch $@

/etc/dovecot/users.conf: /etc/dovecot
	@sudo touch $@


/etc/postfix:
	@sudo mkdir -p $@

/etc/postfix/main.cf: /etc/postfix
	# sudo bash -c "docker run -it --rm docker.io/mailcow/postfix:latest cat /etc/postfix/main.cf > $@"
	@sudo touch $@


.PHONY: postconf
postconf:

	# Configuring email folder
	$(POSTCONF) -e 'virtual_mailbox_base = /srv/dovecot'

	# Configuring virtual transport
	$(POSTCONF) -e 'virtual_transport = dovecot'

	# Configuring Dovecot destination recipient limit
	$(POSTCONF) -e 'dovecot_destination_recipient_limit = 1'

