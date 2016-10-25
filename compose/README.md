## Docker Compose

This is the folder in which [Systemapic Cloud Server](https://systemapic.com)
is built and run.

## Usage
- To build all images: `./build_all.sh`
- To start server and all containers: `./restart.sh`
- To stop all containers : `./kill.sh`

## Configuration

The `common.yml` file describes services, while domain specific `.yml`
file (eg. `dev.systemapic.com.yml`) overrides common and adds specific
stores, environment, etc.

Configurations for containers are mounted from `config/$SYSTEMAPIC_DOMAIN/`
folder on the host system, from `common.yml` file. For example:
```yml
redis:
  image: redis:latest
  volumes:
    - ../../config/${SYSTEMAPIC_DOMAIN}:/systemapic/config

```

Thus, each container has available config for its relevant domain in
`/systemapic/config` folder (inside container).

Domain will be chosen automatically by checking `SYSTEMAPIC_DOMAIN`
env variable on host. This ENV must be set.

The `.yml` files decides what runs, which containers are connected
to each other, etc.

For example, if `SYSTEMAPIC_DOMAIN=dev.systemapic.com`, then
`dev.systemapic.com.yml` compose setup will be run, and configuration from
`config/dev.systemapic.com/` will be used.


## References:
[Docker compose](https://docs.docker.com/compose/)