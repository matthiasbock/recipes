Ansible modules exist for partitioning, formatting and mounting hard disk partitions as well as for altering fstab and crypttab. I would like to specify a host's disk configuration in the host_vars directory of my Ansible inventory in a manner similar to the way it is done attached. Is that a good idea or are there already similarly convenient ways to configure a disk setup in YAML, JSON etc.? Would you adapt from the attached YAML to the existing Ansible modules using a role or would a different approach be more appropriate?

disks:
- id: ata-Samsung_SSD_850_EVO_1TB_S2RXNX0XA12345X
   type: gpt
   partitions:
   sda1:
     uuid: 3fd93f1e-6dca-425a-a10d-334480503ec4
     part_uuid: ce236d37-3b8e-374e-907c-d48cafde97f0
     type: ext4
     state: mounted
     mount:
       path: /
       options: rw,exec,dev,auto

Add support for LVM2 physical volumes, volume groups and volumes. Add support for btrfs, vfat and ntfs filesystems as well as filesystem labels. However, the packages required for their support shall only be installed when the respective filesystem is selected. Generate an example YAML which uses LVM2. All tasks shall be idempotent. If a partition has a valid file system, then the disk shall not be altered and an error shall be raised, unless a variable "force" is set to true. The validity of a partition is determined by analyzing the binary content of the first couple of sectors read from a partition.


Use a list for the "partitions" section, instead of a dictionary. Add support for LUKS encrypted partitions. Add the capability to generate such a YAML by inspecting an already set-up host.

Add tasks updating fstab: When a partitions is formatted, any existing entry pointing to that partition, regardless of whether it is specified as /dev/..., UUID=..., PART_UUID=... or differently, shall  be commented out and an updated entry shall be added below it.

Similarly to fstab, add tasks updating crypttab. Add support for MBR. Invoke systemd daemon-reload, where appropriate. When a LUKS partition is created and no password or keyfile is specified, then  generate a strong password and store it in a locally runnning instance of KeePassXC. When a password is required to unlock a LUKS partition, then request one from KeePassXC. The keyring to use for encryption keys shall be globally configurable.

