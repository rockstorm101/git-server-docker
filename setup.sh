#!/bin/sh
set -ex

# if [ -n "$DEBUG" ]; then set -x; fi

# if [ -d "${SSH_AUTHORIZED_KEYS_PATH}" ]; then
# 	cd /home/git
# 	cat "${SSH_AUTHORIZED_KEYS_PATH}"/*.pub > .ssh/authorized_keys
# 	chown -R git:git .ssh
# 	chmod 700 .ssh
# 	chmod -R 600 .ssh/*
# else
#   echo "Folder ${SSH_AUTHORIZED_KEYS_PATH} not found"
#   exit 1
# fi

# Let the git user own his stuff
# chown -R ${GIT_USER}:${GIT_GROUP} ${SSH_AUTHORIZED_KEYS_PATH} 

if [ ! -f "${SSH_AUTHORIZED_KEYS_FILE}" ]; then
    echo "File '${SSH_AUTHORIZED_KEYS_FILE}' not found.";
    echo "No user will be able to log in."
fi

# Make the git user the onwer of all repositories
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

# Start the ssh server
/usr/sbin/sshd -D
