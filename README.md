# Git Server Docker

This is a simple Docker image containing a Git server only accessible
via SSH.

Re-implementation heavily based on [jkarlosb's code][1].

[1]: https://github.com/jkarlosb/git-server-docker

## Usage

Customise `docker-compose.yml.sample` for your setup and save it as
`docker-compose.yml`. Then run:

```
docker-compose up -d
```
