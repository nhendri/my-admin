# Ansible Playbook For Docker Host Provisioning

This playbook contains roles to prepare and (to a degree) harden a Centos7 host for additional configuration and to provision the host as a simple Docker CE host. 

To run the playbook, update the hosts file at `./playbooks/inventory/hosts` and then run `./runPlaybook.sh` with the `-i` flag set - `./runPlaybook.sh -i inventory/hosts docker_host.yml`. 
