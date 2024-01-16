#!/bin/sh

set -eu

warn() { echo "warning: ${1}" >&2; }

if [ -n "${DEBUG-}" ]; then set -x; fi

# Set specific UID and GID for the git user
if [ -n "${GIT_USER_UID-}" ]; then

    if [ -z "${GIT_USER_GID-}" ]; then
        GIT_USER_GID="${GIT_USER_UID}";
    fi

    # Due to no `usermod` command on Alpine Linux, we need to
    # delete and re-add the git user
    # `deluser` deletes both the user and the group
    deluser "${GIT_USER}"
    addgroup -g "${GIT_USER_GID}" "${GIT_GROUP}"
    adduser \
        --gecos 'Git User' \
        --shell "$(which git-shell)" \
        --uid "${GIT_USER_UID}" \
        --ingroup "${GIT_GROUP}" \
        --no-create-home \
        --disabled-password \
        "${GIT_USER}"
    if ! tmp=$(echo "${GIT_USER}:12345" | chpasswd 2>&1); then
        echo "$tmp"; exit 1
    fi
fi

# Change password of the git user
# A password on file is preferred over the environment variable one
if [ -n "${GIT_PASSWORD_FILE-}" ]; then
    if [ -f "${GIT_PASSWORD_FILE}" ]; then
        echo "${GIT_USER}:$(cat "${GIT_PASSWORD_FILE}")" | chpasswd
    else
        warn "File '${GIT_PASSWORD_FILE}' not found."
        warn "Password for ${GIT_USER} is unchanged."
    fi
elif [ -n "${GIT_PASSWORD-}" ]; then
    echo "${GIT_USER}":"${GIT_PASSWORD}" | chpasswd
fi

# Make the git user the onwer of all repositories and (re)set file
# permissions
if [ -d "${GIT_REPOSITORIES_PATH}" ]; then
    cd "${GIT_REPOSITORIES_PATH}"/.
    chown -R "${GIT_USER}":"${GIT_GROUP}" .
    find . -type f -exec chmod u=rwX,go=rX '{}' \;
    find . -type d -exec chmod u=rwx,go=rx '{}' \;
else
    warn "Directory '${GIT_REPOSITORIES_PATH}' not found."
fi

# Fetch an `authorized_keys` file from an URL if provided
if [ -n "${SSH_AUTHORIZED_KEYS_URL-}" ]; then
    mkdir -p "${GIT_HOME}/.ssh"
    wget -q -O "${SSH_AUTHORIZED_KEYS_FILE}" "${SSH_AUTHORIZED_KEYS_URL}" || \
        warn "Failed to fetch authorized keys from URL."
fi

# Make the git user the owner of his home directory
# Required by the SSH server to allow public key login
if [ -f "${SSH_AUTHORIZED_KEYS_FILE}" ]; then
    chown -R "${GIT_USER}":"${GIT_GROUP}" "${GIT_HOME}"
else
    warn "File '${SSH_AUTHORIZED_KEYS_FILE}' not found."
    warn "Login using public keys will not be available."
fi

# Replace host SSH keys (if given)
if [ -n "${SSH_HOST_KEYS_PATH-}" ]; then
    if [ -d "${SSH_HOST_KEYS_PATH}" ]; then
        cd /etc/ssh
        rm -rf ssh_host_*
        cp "${SSH_HOST_KEYS_PATH}"/ssh_host_* .
        chmod 600 ssh_host_*
        chmod 644 ssh_host_*.pub
    else
        warn "Directory '${SSH_HOST_KEYS_PATH}' not found."
        warn "Default SSH host keys will be used instead."
    fi
fi

# Configure the SSH server configuration file
SSHD_CONFIG_FILE='/etc/ssh/sshd_config'
if [ -n "${SSH_AUTH_METHODS-}" ]; then
    sed -i "s/.*AuthenticationMethods.*//g" ${SSHD_CONFIG_FILE}
    echo "AuthenticationMethods ${SSH_AUTH_METHODS}" >> ${SSHD_CONFIG_FILE}
fi

# Link the repositories folder on git user's home directory
if [ -n "${REPOSITORIES_HOME_LINK-}" ]; then
    if [ -d "${REPOSITORIES_HOME_LINK}" ]; then
        ln -sf "${REPOSITORIES_HOME_LINK}" "${GIT_HOME}"
    else
        warn "Directory '${REPOSITORIES_HOME_LINK}' not found."
        warn "Home link not created."
    fi
fi
