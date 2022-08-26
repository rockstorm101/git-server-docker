FROM alpine:3.16 AS standard

RUN set -ex; \
    apk add --no-cache \
        git=2.36.2-r0 \
        openssh=9.0_p1-r2 \
    ;

# Generate SSH host keys
RUN ssh-keygen -A

# Define variables
ENV GIT_USER=git \
    GIT_GROUP=git
ENV GIT_HOME=/home/${GIT_USER}
ENV SSH_AUTHORIZED_KEYS_FILE=${GIT_HOME}/.ssh/authorized_keys \
    GIT_REPOSITORIES_PATH=/srv/git

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

COPY setup.sh /sbin/setup

EXPOSE 22

ENTRYPOINT ["/sbin/setup"]
CMD ["/usr/sbin/sshd", "-D"]


FROM standard AS docker

RUN set -ex; apk add --no-cache docker-cli=20.10.16-r2
