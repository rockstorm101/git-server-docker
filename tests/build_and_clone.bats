#!/usr/bin/env bats

_curdir=$(pwd)
_docker='docker'
_tag="git-server:test"
_container="git-server"

setup_file() {
    # Set test environment up
    ln -s tests/fixtures .

    # Build docker image
    $_docker build --tag $_tag .
}

teardown_file() {
    cd "$_curdir" && rm -f ./fixtures
}

teardown() {
    $_docker stop $_container || true
    $_docker rm $_container || true
}

image_up() {
    # Brings Docker image up
    # Every argument given is passed verbatim to `docker run`
    cd "$_curdir"
    $_docker run --detach \
             --name ${_container} \
             --env DEBUG="True" \
             --env SSH_HOST_KEYS_PATH="/tmp/host-keys" \
             --volume ./fixtures/repos:/srv/git \
             --volume ./fixtures/host-keys:/tmp/host-keys:ro \
             --publish 2222:22 \
             "$@" \
             $_tag \
             /usr/sbin/sshd -D -e

    sleep 8
    # $_docker logs $_container
}

clone() {
    # Attempt to clone a repo from given URL
    _tmpdir=$(mktemp -d)
    cd "$_tmpdir"
    git clone "${1-ssh://git@localhost:2222/srv/git/projects/test-repo.dc.git}"
}

@test "Basic configuration" {
    image_up
    clone
}

@test "Read password from file (6798)" {
    tmp_file=$(mktemp)
	echo "6789" > $tmp_file
    image_up --env GIT_PASSWORD_FILE="/run/secrets/git_password" \
             --volume ${tmp_file}:/run/secrets/git_password:ro
    clone
}

@test "Change user ID" {
    image_up --env GIT_USER_UID="1005"
	[ $(stat -c "%u" tests/fixtures/repos/projects/test-repo.dc.git) -eq 1005 ]
	[ $(stat -c "%g" tests/fixtures/repos/projects/test-repo.dc.git) -eq 1005 ]
    clone
}

@test "Test cloning using shortened URLs" {
    # Note that this test requires the following configuration to work
    # ```
    # $ cat ~/.ssh/config
    # [...]
    # Host local
    #     HostName localhost
    #     User git
    #     Port 2222
    # ```
    if ! grep "Host local" ~/.ssh/config; then
        skip "No local configuration found"
    fi
    image_up --env REPOSITORIES_HOME_LINK="/srv/git/projects"
    clone local:projects/test-repo.dc.git
}

@test "Test cloning using SSH keys" {
    if ! _key_file=$(ls ~/.ssh/*.pub); then
        skip "No public key found"
    fi
    tmp_key_file=$(mktemp)
    cp $_key_file $tmp_key_file
    image_up --volume $tmp_key_file:/home/git/.ssh/authorized_keys \
             --env SSH_AUTH_METHODS="publickey keyboard-interactive"
    clone
}
