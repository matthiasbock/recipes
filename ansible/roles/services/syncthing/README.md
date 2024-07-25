
# Syncthing

This Ansible role implements installation of a Docker container
with a dedicated network and IPv4 address
running a Syncthing client on a remote host.

The container uses **LetsEncrypt SSL certificates** for the web interface.

The container periodically reports its **health status** by checking,
if the configured ports are connectable.

Container health is also reported via a **Prometheus** file.

See `defaults/main.yml` for configurable options.

