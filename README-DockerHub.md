# Git Server Docker
[![Test Build Status][b1]][2]
[![Docker Image Size][b2]][2]
[![Docker Pulls][b3]][2]

Simple Docker image containing a Git server accessible via SSH.

Image source at: https://github.com/rockstorm101/git-server-docker.


## Basic Usage

```
docker run -v git-repositories:/srv/git -p 2222:22 rockstorm/git-server
```

Your server should be accessible on port 2222 via:

```
git clone ssh://git@localhost:2222/srv/git/your-repo.git
```

The default password for the git user is `12345`.


## Other Features

The image allows much more use cases which are detailed in the [source
README][2]:
 - Setup custom passwords
 - Use SSH public keys
 - Setup custom host SSH keys
 - Enable Git URLs without an absolute path
 - Disable git user interactive login
 - Set git user UID and GID

[2]: https://github.com/rockstorm101/git-server-docker


## Supported Tags and Variants

See [Variants][5] and [Tagging Scheme][6].

[5]: https://github.com/rockstorm101/git-server-docker#variants
[6]: https://github.com/rockstorm101/git-server-docker#tagging-scheme


## License

View [license information][7] for the software contained in this
image.

As with all Docker images, these likely also contain other software
which may be under other licenses (such as Bash, etc from the base
distribution, along with any direct or indirect dependencies of the
primary software being contained).

As for any pre-built image usage, it is the image user's
responsibility to ensure that any use of this image complies with any
relevant licenses for all software contained within.

[7]: https://github.com/rockstorm101/git-server-docker/blob/master/LICENSE


[b1]: https://img.shields.io/github/actions/workflow/status/rockstorm101/git-server-docker/test-build.yml?branch=master
[b2]: https://img.shields.io/docker/image-size/rockstorm/git-server/latest
[b3]: https://img.shields.io/docker/pulls/rockstorm/git-server
