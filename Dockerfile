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
ENV GIT_USER=git \
    GIT_GROUP=git
ENV GIT_HOME=/home/${GIT_USER} \
    SSH_AUTHORIZED_KEYS_FILE=${GIT_HOME}/.ssh/authorized_keys \
    GIT_REPOSITORIES_PATH=/srv/git \
    SETUP_FILE=/sbin/setup

# Create the git user and enable login by assigning a simple password
# Note that BusyBox implementation of `adduser` differs from Debian's
# and therefore options behave slightly differently
RUN set -eux; \
    adduser --disabled-password --shell "$(which git-shell)" "${GIT_USER}"; \
    echo "${GIT_USER}:12345" | chpasswd

# Restrict git user to git commands
# See `git-shell(1)`
COPY git-shell-commands ${GIT_HOME}/git-shell-commands
RUN set -eux; \
    cd ${GIT_HOME}/git-shell-commands; \
    cmds="ls mkdir rm vi"; \
    for c in $cmds; do \
        ln -s $(which $c) .; \
    done;

# Delete Alpine welcome message
RUN rm /etc/motd

COPY setup.sh ${SETUP_FILE}

EXPOSE 22

CMD ${SETUP_FILE}
