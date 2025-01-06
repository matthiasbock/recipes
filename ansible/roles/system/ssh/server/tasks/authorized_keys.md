
# authorized_keys

Distributes SSH public keys from the local to the remote host to enable password-less login.

Requirements: None

Role Variables:

* `ssh_local_user`: The username on the Ansible control machine where the key is located
* `ssh_remote_user`: The username on the remote hosts where the key should be added

Dependencies: None

## Example Playbook

```yaml
---
- hosts: all
  become: true
  gather_facts: false
  roles:
    - role: system/ssh/server
      tasks_from: authorized_keys
      vars:
        ssh_local_user: my_local_user
        ssh_remote_user: my_remote_user
```

