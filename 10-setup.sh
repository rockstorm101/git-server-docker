#!/bin/sh
set -eu

if [ -n "${DEBUG-}" ]; then set -x; fi

# Set specific UID and GID for the git user
if [ -n "${GIT_USER_UID-}" ] && \
       [ "${GIT_USER_UID}" != "$(id -u "${GIT_USER}")" ] && \
       [ "${GIT_USER_UID}" != 0 ]; then
    if [ -z "${GIT_USER_GID}" ]; then
        GIT_USER_GID="${GIT_USER_UID}";
    fi
    # Due to no `usermod` on Alpine Linux, we need to delete and
    # re-add the git user
    # `deluser` deletes both the user and the group
    deluser "${GIT_USER}"
    addgroup -g "${GIT_USER_GID}" "${GIT_GROUP}"
    adduser \
        --gecos 'Linux User' \
        --shell "$(which git-shell)" \
        --uid "${GIT_USER_UID}" \
        --ingroup "${GIT_GROUP}" \
        --no-create-home \
        --disabled-password "${GIT_USER}"
    echo "${GIT_USER}:12345" | chpasswd
fi

# Change password of the git user
# A password on file is preferred over the environment variable one
if [ -n "${GIT_PASSWORD_FILE-}" ]; then
    if [ -f "${GIT_PASSWORD_FILE}" ]; then
        echo "${GIT_USER}:$(cat "${GIT_PASSWORD_FILE}")" | chpasswd
    else
        echo "File '${GIT_PASSWORD_FILE}' not found."
        echo "Password for ${GIT_USER} is unchanged."
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
    echo "Directory '${GIT_REPOSITORIES_PATH}' not found."
fi

# Make the git user the owner of his home directory
# Required by the SSH server to allow public key login
if [ -f "${SSH_AUTHORIZED_KEYS_FILE}" ]; then
    chown "${GIT_USER}":"${GIT_GROUP}" "${GIT_HOME}"
else
    echo "File '${SSH_AUTHORIZED_KEYS_FILE}' not found."
    echo "No user will be able to log in using a public key."
fi

# Replace host SSH keys (if given)
if [ -n "${SSH_HOST_KEYS_PATH-}" ]; then
    if [ -d "${SSH_HOST_KEYS_PATH}" ]; then
        cd /etc/ssh
        rm -rf ssh_host_*
        cp "${SSH_HOST_KEYS_PATH}"/ssh_host_* .
    else
        echo "Directory '${SSH_HOST_KEYS_PATH}' not found."
        echo "Default SSH host keys will be used instead."
    fi
fi

# Link the repositories folder on git user's home directory
if [ -n "${REPOSITORIES_HOME_LINK-}" ]; then
    if [ -d "${REPOSITORIES_HOME_LINK}" ]; then
        ln -sf "${REPOSITORIES_HOME_LINK}" "${GIT_HOME}"
    else
        echo "Directory '${REPOSITORIES_HOME_LINK}' not found."
        echo "Home link not created."
    fi
fi
