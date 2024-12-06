
# Syncthing

This Ansible role implements installation and configuration of a Docker container running a Syncthing client.
The container is started with a configurable IPv4 address
in a dedicated container network with a configurable subnet mask.

For the Syncthing web interface,
**LetsEncrypt SSL certificates** from the container host
can be bound to be available in the container.

The container periodically performs a **health check**
and reports the resulting metrics via a **Prometheus** file.

See `defaults/main.yml` for configurable options.

## Health check

The health check is implemented as a shell script, which is added to the image upon creation.
The script is set up as `healthcheck` command for the image,
such that it is executed regularly by any deriving container.
The script is executed by /bin/sh, since the upstream Syncthing image does not contain a bash executable.

Within the script, several checks are performed to determine the health of the container:

* The script attempts to connect to several TCP and UDP ports. Any connection error is considered a `healthcheck` failure.
* Syncthing's status is requested using the REST API. Any status other than `OK` is considered a `healthcheck` failure.

## TODO: Improve healthcheck

### The health check shall also look for files indicating a synchronization conflict

Upon sync conflicts, Syncthing creates files with the following naming pattern:

~~~
<basename>.sync-conflict-20241027-111858-BJV4UCL.<file extension>
~~~

Such files could e.g. be discovered using find:

~~~sh
find \
  /path/to/syncthing/data/ \
  -type f \
  -regextype posix-extended \
  -iregex '.*/.*\.sync-conflict-[0-9]{8}-[0-9]{6}-[A-Z0-9]{7}\..*' \
  -print
~~~

Checking for the presence of any matching file:

~~~sh
find /path/to/syncthing/data/ -name "*.sync-conflict*" -quit

if [ $? -eq 0 ]; then
  sync_conflict_found=false
else
  sync_conflict_found=true
fi

if [ "$sync_conflict_found" = true ]; then
  echo "Sync conflict detected!"
  # ... take appropriate action ...
else
  echo "No sync conflicts found."
fi
~~~

or more concise:

~~~sh
if ! find /path/to/syncthing/data/ -name "*.sync-conflict*" -quit; then
  echo "Sync conflict detected!"
  # ... take appropriate action ...
else
  echo "No sync conflicts found."
fi
~~~

### The health check shall also detect relevant error messages in the log

The healthcheck script (see templates/) shall follow the container's log output.
When a relevant error message is found, the healthcheck shall report the container as 'unhealthy'.

Examples:
* ...when Syncthing was unable to open or use a folder, which is configured as a share in its configuration file
* ...when one or several files have encountered synchronization conflicts or could not be synchronized

### The health check shall also check, if there is sufficient disk space available for all shared folders

When Syncthing stops one or several shares,
because the respectively configured minimal amount of available disk space becomes unavailable,
the healthcheck shall report the container as 'unhealthy'.

When a disk, that is used for one or several shares,
becomes read-only, but at least one share is configured writable,
then the container shall be reported as 'unhealthy'.
If possible, Syncthing shall be stopped in this case,
to prevent synchronization conflicts.

