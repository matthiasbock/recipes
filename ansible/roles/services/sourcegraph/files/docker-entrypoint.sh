#!/bin/bash

# Load nftables rules
nft -f /etc/nftables.conf

# Run the original entrypoint
exec /sbin/tini -- /usr/local/bin/sourcegraph-server
