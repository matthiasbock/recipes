#!/bin/bash

DOMAINS=$(grep -v ^# /etc/postfix/users.conf | fgrep '@' | cut -d: -f1 | cut -d@ -f2 | sort -u | tr '\\n' ',')
echo "Mailbox domains: $DOMAINS"
postconf -e "virtual_mailbox_domains = $DOMAINS"
# if fgrep virtual_mailbox_domains /etc/postfix/main.cf > /dev/null; then
#     echo "virtual_mailbox_domains = $DOMAINS" >> /etc/postfix/main.cf
# else
#     sed -i "s/^virtual_mailbox_domains =.*$/virtual_mailbox_domains = $DOMAINS/" /etc/postfix/main.cf
# fi

exec "$@"
