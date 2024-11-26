
# Syncthing

This Ansible role implements installation of a Docker container
with a dedicated network and IPv4 address
running a Syncthing client on a remote host.

The container uses **LetsEncrypt SSL certificates** for the web interface.

The container periodically reports its **health status** by checking,
if the configured ports are connectable.

Container health is also reported via a **Prometheus** file.

See `defaults/main.yml` for configurable options.

## TODO: Improved healthcheck

### Healthcheck shall detect relevant error messages in the log

The healthcheck script (see templates/) shall follow the container's log output.
When a relevant error message is found, the healthcheck shall report the container as 'unhealthy'.

Examples:
* ...when Syncthing was unable to open or use a folder, which is configured as a share in its configuration file
* ...when one or several files have encountered synchronization conflicts or could not be synchronized

### Healthcheck shall check if there is sufficient disk space

When Syncthing stops one or several shares,
because the respectively configured minimal amount of available disk space becomes unavailable,
the healthcheck shall report the container as 'unhealthy'.

When a disk, that is used for one or several shares,
becomes read-only, but at least one share is configured writable,
then the container shall be reported as 'unhealthy'.
If possible, Syncthing shall be stopped in this case,
to prevent synchronization conflicts.

