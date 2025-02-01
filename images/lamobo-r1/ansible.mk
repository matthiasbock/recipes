
.PHONY: ansible
ansible:
	ansible-playbook -v $(DIR_LAMOBO_IMAGE)/lamobo-image.yml

