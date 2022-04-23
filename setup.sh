#!/bin/sh
set -e

if [ -n "${DEBUG}" ]; then set -x; fi

# Throw a warning if authorized_keys is not found
if [ ! -f "${SSH_AUTHORIZED_KEYS_FILE}" ]; then
    echo "File '${SSH_AUTHORIZED_KEYS_FILE}' not found.";
    echo "No user will be able to log in using a public key."
fi

# Change password of the git user using an environment variable
if [ -n "${GIT_PASSWORD}" ]; then
    echo "${GIT_USER}":"${GIT_PASSWORD}" | chpasswd
fi

# Change password of the git user using a file
if [ -n "${GIT_PASSWORD_FILE}" ]; then
    if [ -f "${GIT_PASSWORD_FILE}" ]; then
		echo "${GIT_USER}:$(cat "${GIT_PASSWORD_FILE}")" | chpasswd
    else
        echo "File '${GIT_PASSWORD_FILE}' not found."
        echo "Password for ${GIT_USER} is unchanged."
    fi
fi

# Make the git user the onwer of all repositories
export GIT_REPOSITORIES_PATH
if [ -d "${GIT_REPOSITORIES_PATH}" ]; then
    chown -R "${GIT_USER}":"${GIT_GROUP}" "${GIT_REPOSITORIES_PATH}"/.
else
    echo "Directory '${GIT_REPOSITORIES_PATH}' not found."
fi

# Replace host SSH keys (if given)
if [ -n "${SSH_HOST_KEYS_PATH}" ]; then
    if [ -d "${SSH_HOST_KEYS_PATH}" ]; then
        cd /etc/ssh
        rm -rf ssh_host_*
        cp "${SSH_HOST_KEYS_PATH}"/ssh_host_* .
    else
        echo "Directory '${SSH_HOST_KEYS_PATH}' not found."
        echo "Default SSH host keys will be used instead."
    fi
fi

# Link the repositories folder on git user's home directory to access
# repos with:
#     git clone [user@]host.xz:repo.git
# instead of:
#     git clone [user@]host.xz:/srv/git/repo.git
if [ -n "${REPOSITORIES_HOME_LINK}" ]; then
    if [ -d "${REPOSITORIES_HOME_LINK}" ]; then
        ln -sf "${REPOSITORIES_HOME_LINK}" "${HOME_GIT_USER}"
    else
        echo "Directory '${REPOSITORIES_HOME_LINK}' not found."
        echo "Home link not created."
    fi
fi

# Add the git user to the group with write access to the docker socket
docker_socket_path="/var/run/docker.sock"
if [ -S "${docker_socket_path}" ]; then
	docker_group="$(stat -c '%G' ${docker_socket_path})"
	docker_group_id="$(stat -c '%g' ${docker_socket_path})"
	if [ "${docker_group}" = "UNKNOWN" ]; then
		docker_group="docker"
		addgroup -g "${docker_group_id}" "${docker_group}"
	fi
	addgroup "${GIT_USER}" "${docker_group}"
fi


# Start the ssh server
/usr/sbin/sshd -D
