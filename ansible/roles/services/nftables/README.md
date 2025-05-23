
## Automatic application of firewall rules

This role provides tasks to install and configure a modified nftables service,
which is started as soon as the network comes up and
applies the rules defined in `/etc/nftables.conf`.

Systemd comes with a default unit, `nftables.service`,
which is a little different though.

## TODO: Fallback to maintenance mode

Should applying the rules fail for any reason,
e.g. because `/etc/nftables.conf` is missing,
not executable or has syntax errors,
a strict fallback configuration is applied,
which allows only SSH access to the host,
blocking all other traffic.

