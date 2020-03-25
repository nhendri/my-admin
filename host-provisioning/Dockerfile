# Guided by https://github.com/walokra/docker-ansible-playbook

# Base Image - Could probably be tag :latest
FROM alpine:latest

# Ansible Version
ENV ANSIBLE_VERSION 2.7.2

ENV BUILD_PACKAGES bash curl tar openssh-client sshpass git python py-boto py-dateutil py-httplib2 py-jinja2 py-paramiko py-pip py-yaml ca-certificates

# Add entrypoint script to image - this script runs ssh-agent and ssh-add's the passed in key pair at runtime
COPY controller_files/image_entrypoint/entrypoint.sh /root/entrypoint.sh

RUN chmod +x /root/entrypoint.sh

# Build Image
RUN \
  # dependencies required for build (will be removed at the end)
  apk --update add --virtual build-dependencies gcc musl-dev libffi-dev openssl-dev python-dev && \
  # making sure apk and its packages are up to date
  apk update && apk upgrade && \
  # Adding Python stuff 
  apk add --no-cache ${BUILD_PACKAGES} && \
  pip install --upgrade pip && \
  pip install python-keyczar docker-py && \
  # installing Ansible
  pip install ansible==${ANSIBLE_VERSION} && \
  # removing build dependency packages for a nice clean image
  apk del build-dependencies && \
  rm -rf /var/cache/apk/*

# Additional ansible environment variables
ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
ENV ANSIBLE_SSH_PIPELINING True
ENV PYTHONPATH /ansible/lib
ENV PATH /ansible/bin:$PATH
ENV ANSIBLE_LIBRARY /ansible/library

# /ansible/playbooks is where the playbook is mounted
WORKDIR /ansible/playbooks

ENTRYPOINT ["/root/entrypoint.sh"]
