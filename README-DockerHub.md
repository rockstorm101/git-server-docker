# Git Server Docker
[![Test Build Status][1]][2]
[![Docker Image Size][3]][2]
[![Docker Pulls][4]][2]

This is a simple Docker image containing a Git server accessible via
SSH. (It can also contain Docker CLI, see [Variants](#variants))

Image source at https://github.com/rockstorm101/git-server-docker.

[1]: https://img.shields.io/github/workflow/status/rockstorm101/git-server-docker/Test%20Docker%20Build
[2]: https://github.com/rockstorm101/git-server-docker
[3]: https://img.shields.io/docker/image-size/rockstorm/git-server/latest
[4]: https://img.shields.io/docker/pulls/rockstorm/git-server


## Usage

### Basic use case:

```shell
docker run --detach \
  --name git-server \
  --volume git-repositories:/srv/git \
  --publish 2222:22 \
  rockstorm/git-server
```

Your server should be accessible on port 2222 via:

```
git clone ssh://git@localhost:2222/srv/git/your-repo.git
```

The default password for the git user is `12345`.

### Other Features

The image allows much more use cases which are detailed in the [source README][2]:
 - Setup custom passwords
 - Use SSH public keys
 - Setup custom host SSH keys
 - Enable Git URLs without an absolute path
 - Enable Docker CLI to run other CI/CD containers
 - Disable git user interactive login
 - Set git user UID and GID


## Variants

All images are based on the latest stable image of [Alpine Linux][5].

### `git-server:<git-version>`

Default image. It contains just git and SSH.

### `git-server:<git-version>-docker`

This image includes the Docker CLI. With this addition the git server
will be able to start other containers for things such as running
CI/CD actions. In this case you would need to mount the host's Docker
socket to your git server container[^1]. This would look like the
following on your docker-compose.yml file:

```yaml
services:
  git-server:
    ...
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

[5]: https://hub.docker.com/_/alpine


## License

View [license information][6] for the software contained in this
image.

As with all Docker images, these likely also contain other software
which may be under other licenses (such as Bash, etc from the base
distribution, along with any direct or indirect dependencies of the
primary software being contained).

As for any pre-built image usage, it is the image user's
responsibility to ensure that any use of this image complies with any
relevant licenses for all software contained within.

[6]: https://github.com/rockstorm101/git-server-docker/blob/master/LICENSE

