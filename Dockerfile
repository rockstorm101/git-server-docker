FROM alpine:3.15

RUN set -eux; \
  apk add --no-cache \
    openssh \
    git \
  ;

# Generate SSH host keys
RUN ssh-keygen -A

# Define variables
ENV GIT_USER git
ENV GIT_GROUP git
ENV HOME_GIT_USER /home/${GIT_USER}
ENV GIT_REPOSITORIES_PATH /srv/git
ENV SSH_AUTHORIZED_KEYS_PATH ${HOME_GIT_USER}/.ssh
ENV SSH_AUTHORIZED_KEYS_FILE ${SSH_AUTHORIZED_KEYS_PATH}/authorized_keys
ENV SETUP_FILE /sbin/setup

# Create the git user and enable login by assigning a simple password
# Note that BusyBox implementation of `adduser` differs from Debian's
# and therefore options behave slightly differently
RUN set -eux; \
  adduser --disabled-password --shell /usr/bin/git-shell "${GIT_USER}"; \
  echo "${GIT_USER}:12345" | chpasswd

# Create the folder(s) to hold the authorized_keys file
RUN mkdir -p ${SSH_AUTHORIZED_KEYS_PATH}

# Restrict git user to git commands
# See `man git-shell`
COPY git-shell-commands /home/${GIT_USER}/git-shell-commands

COPY setup.sh ${SETUP_FILE}

EXPOSE 22

CMD ${SETUP_FILE}
