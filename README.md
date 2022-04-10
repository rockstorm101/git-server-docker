# Git Server Docker
[![GitHub Workflow Status][4]][6]
[![Docker Image Size][5]][6]

This is a simple Docker image containing a Git server accessible via
SSH.

## Usage

Customise [`docker-compose.yml.sample`][1] for your setup and save it
as `docker-compose.yml`. Then run:

```shell
docker-compose up -d
```

[1]: https://github.com/rockstorm101/git-server-docker/blob/master/docker-compose.yml.sample

### Basic Configuration

Two volumes are required as a bare minimum. One with the path to where
your git repositories are stored and another one with the path to your
file with SSH authentication keys for the users that will be allowed
to interact with the server. These are set in the docker-compose.yml
file as:

```yml
    volumes:
      - /path/to/your/repos:/srv/git
      - /path/to/authorized_keys:/home/git/.ssh/authorized_keys:ro
```

### Custom SSH Host Keys

The default host keys are generated during image build and are the
same for every container which uses this image. This is a security
risk and therefore the use of a custom set of keys is highly
recommended. This will also ensure keys are persistent if the image is
upgraded.

To enable custom SSH host keys set the `SSH_HOST_KEYS_PATH` variable
to a location such as `/tmp/host-keys` and mount a folder with your
custom keys on the server. The setup process with replace the default
keys with these ones. This would look like the following on your
docker-compose.yml file:

```yml
    environment:
      SSH_HOST_KEYS_PATH: /tmp/host-keys
    volumes:
      - /path/to/host-keys:/tmp/host-keys:ro
```

### Enable Git URLs Without Absolute Path

By default, git URLs to you repositories will be in the form of:

```
git clone git@example.com:2222/srv/git/project/repository.git
```

By setting the environment variable `REPOSITORIES_HOME_LINK` to
e.g. `/srv/git/project` a link will be created into the git user home
directory so that your git URLs don't require the repository absolute
path:

```
git clone git@example.com:project/repository.git
```

To configure this on your docker-compose.yml file:

```yml
    environment:
      REPOSITORIES_HOME_LINK: /srv/git
```

Ref. https://stackoverflow.com/a/39841058

To avoid specifying ports on git URLs you can configure your client
machine by adding the following to your `~/.ssh/config` file:

```
Host my-server
    HostName example.com
    User git
    Port 2222
```

This way your git URLs would look like:
```
git clone my-server:project/repository.git
```

### Custom SSH Daemon Configuration

To apply your own custom SSH daemon configuration simply mount your
`sshd_config` onto the container like:

```yml
    volumes:
      - ./sshd_config.sample:/etc/ssh/sshd_config:ro
```

## License

View [license information][2] for the software contained in this
image.

As with all Docker images, these likely also contain other software
which may be under other licenses (such as Bash, etc from the base
distribution, along with any direct or indirect dependencies of the
primary software being contained).

As for any pre-built image usage, it is the image user's
responsibility to ensure that any use of this image complies with any
relevant licenses for all software contained within.

[2]: https://github.com/rockstorm101/git-server-docker/blob/master/LICENSE

## Credit

Re-implementation heavily based on [jkarlosb's][3] but coded from
scratch.

[3]: https://github.com/jkarlosb/git-server-docker

[4]: https://img.shields.io/github/workflow/status/rockstorm101/git-server-docker/Build%20Docker%20Images
[5]: https://img.shields.io/docker/image-size/rockstorm/git-server/latest
[6]: https://hub.docker.com/r/rockstorm/git-server
