#!/bin/bash

# This little guy is the entrypoint sh that runs your actual ansible-playbook command after taking your runtime-attached ssh config and applying it.

eval "$(ssh-agent)" && \
ssh-add ~/.ssh/id_rsa && \
ansible-playbook "$@"
