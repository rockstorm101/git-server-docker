FROM alpine:3.15

ARG EXTRA_PACKAGES=""
RUN set -eux; \
  apk add --no-cache \
    git=2.34.2-r0 \
    openssh=8.8_p1-r1 \
    $EXTRA_PACKAGES \
  ;

# Generate SSH host keys
RUN ssh-keygen -A

# Define variables
ENV GIT_USER git
ENV GIT_GROUP git
ENV GIT_HOME /home/${GIT_USER}
ENV SSH_AUTHORIZED_KEYS_PATH ${GIT_HOME}/.ssh
ENV SSH_AUTHORIZED_KEYS_FILE ${SSH_AUTHORIZED_KEYS_PATH}/authorized_keys
ENV GIT_SHELL /usr/bin/git-shell
ENV GIT_REPOSITORIES_PATH /srv/git
ENV SETUP_FILE /sbin/setup

# Create the git user and enable login by assigning a simple password
# Note that BusyBox implementation of `adduser` differs from Debian's
# and therefore options behave slightly differently
RUN set -eux; \
  adduser --disabled-password --shell "${GIT_SHELL}" "${GIT_USER}"; \
  echo "${GIT_USER}:12345" | chpasswd

# Create the folder(s) to hold the authorized_keys file
RUN mkdir -p ${SSH_AUTHORIZED_KEYS_PATH}

# Restrict git user to git commands
# See `man git-shell`
COPY git-shell-commands ${GIT_HOME}/git-shell-commands

COPY setup.sh ${SETUP_FILE}

EXPOSE 22

CMD ${SETUP_FILE}
