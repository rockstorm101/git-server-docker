FROM alpine:3.19.1

RUN set -ex; \
    apk add --no-cache \
        git=2.43.0-r0 \
        openssh=9.6_p1-r0 \
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
    addgroup "${GIT_GROUP}"; \
    adduser \
        --gecos "Git User" \
        --ingroup "${GIT_GROUP}" \
        --disabled-password \
        --shell "$(which git-shell)" \
        "${GIT_USER}" ; \
    echo "${GIT_USER}:12345" | chpasswd

# Restrict git user to git commands
# See `git-shell(1)`
COPY git-shell-commands ${GIT_HOME}/git-shell-commands
RUN set -eux; \
    cd ${GIT_HOME}/git-shell-commands; \
    cmds="ls mkdir rm vi"; \
    for c in $cmds; do \
        ln -s $(which $c) .; \
    done

# Delete Alpine welcome message
RUN rm /etc/motd

# Set up entrypoint script and directory
ENV DOCKER_ENTRYPOINT_DIR=/docker-entrypoint.d
RUN set -eux; \
    mkdir ${DOCKER_ENTRYPOINT_DIR}
COPY docker-entrypoint.sh /
COPY 10-setup.sh ${DOCKER_ENTRYPOINT_DIR}

EXPOSE 22

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
