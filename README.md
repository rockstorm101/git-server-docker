# Git Server Docker

This is a simple Docker image containing a Git server accessible via
SSH.

## Usage

Customise [`docker-compose.yml.sample`][2] for your setup and save it as
`docker-compose.yml`. Then run:

```
docker-compose up -d
```

[2]: https://github.com/rockstorm101/git-server-docker/blob/master/docker-compose.yml.sample

## Credit

Re-implementation heavily based on [jkarlosb's][1] but coded from
scratch.

[1]: https://github.com/jkarlosb/git-server-docker
