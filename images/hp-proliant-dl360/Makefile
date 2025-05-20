
SHELL := /bin/bash -o pipefail

# Target medium
DEV_MMC=/dev/mmcblk0
DEV_BOOT=$(DEV_MMC)p1
DEV_ROOT=$(DEV_MMC)p2

# Filesystem on the boot partition (ext4)
FSLABEL_BOOT=server-boot
DEV_FS_BOOT=/dev/disk/by-label/$(FSLABEL_BOOT)

# Encrypted root partition
LUKSLABEL_ROOT=server-root_luks
#DEV_ROOT_CLOSED=/dev/disk/by-label/$(LUKSLABEL_ROOT)
DEV_ROOT_CLOSED=$(DEV_ROOT)

# Opened root partition
NAME_ROOT_OPEN=cryptroot
DEV_ROOT_OPEN=/dev/mapper/$(NAME_ROOT_OPEN)

# Filesystem on the root partition (btrfs)
FSLABEL_ROOT=server-root
DEV_FS_ROOT=/dev/disk/by-label/$(FSLABEL_ROOT)

# Mountpoints
MOUNTPOINT_BOOT=/mnt/mmc/root/boot
MOUNTPOINT_ROOT=/mnt/mmc/root
BOOT_MOUNTED=$(MOUNTPOINT_BOOT)/grub
ROOT_MOUNTED=$(MOUNTPOINT_ROOT)/etc

# Configuration
HOSTNAME=server


.PHONY: all
all:

#
# Partitioning
#
.PHONY: partitions
partitions: $(DEV_BOOT) $(DEV_ROOT)
$(DEV_BOOT) $(DEV_ROOT): $(DEV_MMC)
	@echo Partitioning: $(DEV_MMC)
	# Also set the partition labels
	sudo sfdisk $(DEV_MMC) <<EOF \
label: dos \
,512M,83 \
,,83 \
EOF
	sudo partprobe --summary $(DEV_MMC)

#
# Filesystems
#
.PHONY: format-boot-ext4
format-boot-ext4: $(DEV_BOOT)
	@echo Formatting as ext4: $<
	sudo mkfs -t ext4 -L $(FSLABEL_BOOT) $<

.PHONY: format-root-luks
format-root-luks: $(DEV_ROOT)
	@echo Formatting as LUKS2-encrypted: $<
	sudo cryptsetup luksFormat \
		--label $(LUKSLABEL_ROOT) \
		--batch-mode --verify-passphrase \
		$(DEV_ROOT)

# Open the LUKS2-encrypted partition
.PHONY: open-root-luks
open-root-luks: $(DEV_ROOT_OPEN)
$(DEV_ROOT_OPEN) $(DEV_FS_ROOT): $(DEV_ROOT_CLOSED)
	@echo Opening LUKS2-encrypted partition: $<
	sudo cryptsetup luksOpen $(DEV_ROOT_CLOSED) $(NAME_ROOT_OPEN)

.PHONY: close-root-luks
close-root-luks:
	@echo Closing LUKS2-encrypted partition: $(NAME_ROOT_OPEN)
	sudo cryptsetup luksClose $(NAME_ROOT_OPEN)

# Format the root partition as btrfs
.PHONY: format-root-btrfs
format-root-btrfs: $(DEV_ROOT_OPEN)
#$(DEV_FS_ROOT): 
	@echo Formatting as btrfs: $<
	sudo mkfs.btrfs \
		-d single \
		-m dup \
		--label $(FSLABEL_ROOT) \
		--checksum sha256 \
		$<

#
# Mounting
#
.PHONY: mount
mount: $(BOOT_MOUNTED) $(ROOT_MOUNTED)

$(MOUNTPOINT_BOOT):
	sudo mkdir -p $@

.PHONY: mount-boot
mount-boot: $(BOOT_MOUNTED)
$(BOOT_MOUNTED): $(MOUNTPOINT_BOOT) #$(DEV_FS_BOOT)
	sudo mount $(DEV_FS_BOOT) $(MOUNTPOINT_BOOT)

$(MOUNTPOINT_ROOT):
	sudo mkdir -p $@

.PHONY: mount-root
mount-root: $(ROOT_MOUNTED)
$(ROOT_MOUNTED): $(MOUNTPOINT_ROOT) $(DEV_FS_ROOT)
	sudo mount $(DEV_FS_ROOT) $(MOUNTPOINT_ROOT)

.PHONY: umount
umount:
	sudo sync && sleep 1
	#if [ -e $(BOOT_MOUNTED) ]; then
	sudo umount $(MOUNTPOINT_BOOT) && sleep 1 || true
	#if [ -e $(ROOT_MOUNTED) ]; then
	sudo umount $(MOUNTPOINT_ROOT) && sleep 1 || true
	sudo rmdir -p $(MOUNTPOINT_BOOT) $(MOUNTPOINT_ROOT) 2>/dev/null || true
	sudo cryptsetup luksClose $(NAME_ROOT_OPEN)

#
# Booting
#
.PHONY: grub-install
grub-install: $(ROOT_MOUNTED) $(BOOT_MOUNTED)
	sudo grub-install \
		--target=i386-pc \
		--boot-directory=$(MOUNTPOINT_BOOT) \
		--recheck \
		$(DEV_MMC)

# Start the system in a container
.PHONY: systemd-nspawn
systemd-nspawn: #$(ROOT_MOUNTED) $(BOOT_MOUNTED)
	sudo systemd-nspawn \
		--network-ipvlan wlan0 \
		--property="DeviceAllow=/dev/mapper/control rwm" \
		--bind-ro=/dev/{mapper,disk,dm-{0,1,2,3,4,5,6}} \
		--bind-ro=$(DEV_MMC) \
		--bind-ro=$(DEV_BOOT) \
		--bind-ro=$(DEV_ROOT) \
		--bind-ro=/sys/fs/btrfs \
		-D $(MOUNTPOINT_ROOT)

# Boot the image in a virtual machine
.PHONY: qemu
qemu:
	qemu-system-x86_64 \
		-enable-kvm \
		-m 2048 \
		-drive file=$(DEV_MMC),format=raw

#
# Hostname
#
.PHONY: set-hostname
set-hostname: $(ROOT_MOUNTED)
	sudo echo $(HOSTNAME) > $(MOUNTPOINT_ROOT)/etc/hostname

#
# SSH host key
#
.PHONY: create-ssh-host-key
create-ssh-host-key: $(MOUNTPOINT_ROOT)/etc/ssh/ssh_host_ed25519_key
$(MOUNTPOINT_ROOT)/etc/ssh/ssh_host_ed25519_key: $(ROOT_MOUNTED)
	sudo mkdir -p "$(MOUNTPOINT_ROOT)/etc/ssh"
	sudo ssh-keygen -t ed25519 -f $@ -N '' -C ''
	sudo chown root:root $@
	sudo chmod 600 $@

.PHONY: remove-ssh-host-key
remove-ssh-host-key: $(ROOT_MOUNTED)
	sudo rm --preserve-root -f \
		$(MOUNTPOINT_ROOT)/etc/ssh/ssh_host_*_key{,.pub}

.PHONY: recreate-ssh-host-key
recreate-ssh-host-key: remove-ssh-host-key create-ssh-host-key

#
# SSH key for root
#
.PHONY: create-ssh-key-for-root
create-ssh-key-for-root: $(MOUNTPOINT_ROOT)/root/.ssh/id_ed25519
$(MOUNTPOINT_ROOT)/root/.ssh/id_ed25519: $(ROOT_MOUNTED)
	sudo mkdir -p "$(MOUNTPOINT_ROOT)/root/.ssh"
	sudo ssh-keygen -t ed25519 -f "$(MOUNTPOINT_ROOT)/root/.ssh/id_ed25519" -N '' -C ''
	sudo chown root:root "$(MOUNTPOINT_ROOT)/root/.ssh/id_ed25519"
	sudo chmod 600 "$(MOUNTPOINT_ROOT)/root/.ssh/id_ed25519"
	sudo chmod 644 "$(MOUNTPOINT_ROOT)/root/.ssh/id_ed25519.pub"

.PHONY: remove-ssh-key-for-root
remove-ssh-key-for-root: $(ROOT_MOUNTED)
	sudo rm --preserve-root -vf "$(MOUNTPOINT_ROOT)/root/.ssh/id_ed25519"
	sudo rm --preserve-root -vf "$(MOUNTPOINT_ROOT)/root/.ssh/id_ed25519.pub"

.PHONY: recreate-ssh-key-for-root
recreate-ssh-key-for-root: remove-ssh-key-for-root create-ssh-key-for-root

