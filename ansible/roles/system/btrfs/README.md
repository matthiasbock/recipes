
# Ansible roles for btrfs filesystem maintenance

## Monitor the syslog for btrfs-related messages

When a btrfs filesystem enters forced read-only mode,
the journal/log can be inspected to identify the cause
in order to execute an appropriate reaction.

To that end a systemd unit can be installed using Ansible:

~~~
sudo ansible-playbook -i inventory.yml system/btrfs/syslog-monitor.yml
~~~

## React to transition to forced read-only mode

If the original error points to errors in the journal,
such as a issues with transaction IDs:

~~~
transid verify failed on <number> expected <number> found <number>
~~~

then the following steps can be undertaken automatically
in an attempt to fix the problem:

* disable the syslog monitor
* invoke a sync and wait at most 120 seconds for it to complete
* stop the user.slice to stop all processes that may prevent unmounting the filesystem
* force-unmount the filesystem
* run btrfs rescue zero-log /path/to/blockdev
  * claim control over the current tty
  * log all output to it
  * also log to a file in /root/ (filename incl. timestamp)
* attempt to re-mount the filesystem
  * if mounting is successful, start a btrfs scrub
    * if user.slice was running before, restart it
  * if mounting is unsuccessful, enter systemd rescue or emergency mode

