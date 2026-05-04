---
name: container-cli
description: Use Apple's container CLI to build, run, and manage lightweight Linux containers on Apple Silicon Macs. Invoke when user mentions "container", "Apple container", or needs help with container operations.
allowed-tools: Bash, Read, Glob, Grep
---

# Apple Container CLI

Apple's `container` is a Swift-based tool for creating and running Linux containers as lightweight virtual machines on Apple Silicon Macs. It is OCI-compatible and works with standard container images from registries.

CLI version at time of writing: 0.7.1. Always run `container --version` to check.

## Key Differences from Docker

- Containers run as lightweight VMs on Apple Silicon, not shared-kernel processes
- No Docker daemon -- uses a background builder shim instead
- `container rm` is an alias for `container delete`
- `container ls` is an alias for `container list`
- Images are pulled on demand from OCI registries
- Supports Rosetta for running x86_64 images on ARM
- No `docker-compose` equivalent -- orchestrate manually or script it
- Volume mounts use the same `-v host:guest` syntax
- Port publishing uses `-p host:guest` syntax, same as Docker
- `container build` supports Dockerfiles with multi-stage, build-args, secrets, and `--no-cache`

## Commands Reference

### Build Images

```bash
container build -t myapp:latest .
container build -f docker/Dockerfile.prod -t myapp:prod .
container build --build-arg NODE_VERSION=18 -t myapp .
container build --target production -t myapp:prod .
container build --no-cache -t myapp:fresh .
container build --arch arm64 --arch amd64 -t myapp:multiarch .
container build --secret id=npmrc,env=NPM_TOKEN -t myapp .
container build --secret id=ssh_key,src=~/.ssh/id_rsa -t myapp .
```

### Run Containers

```bash
container run -it ubuntu:latest /bin/bash
container run -d --name web --rm -p 8080:80 nginx:latest
container run --cpus 4 --memory 8G -e NODE_ENV=production node:18 npm start
container run -v ${HOME}/data:/app/data alpine:latest ls /app/data
container run -it --rm --ssh alpine:latest sh
container run --rosetta --arch amd64 --rm python:alpine uname -a
container run -d --name myapp -m 8G -v /path/to/project:/app oven/bun:1-alpine
container run --init ubuntu:latest ./my-app
container run -w /app node:18 npm test
```

### Manage Containers

```bash
container list                                    # List running containers
container list --all                               # List all containers (includes stopped)
container start <name-or-id>                       # Start a stopped container
container kill <name-or-id>                        # Kill a running container
container delete <name-or-id>                      # Delete a container
container delete <id1> <id2>                       # Delete multiple containers
container exec <name-or-id> sh -c "command"        # Run command in running container
container exec -it <name-or-id> sh                 # Interactive shell in container
container logs <name-or-id>                        # Fetch container logs
container inspect <name-or-id>                     # Display container info
container stats                                    # Resource usage for all containers
```

### Builder Management

The builder shim handles image builds. It runs as a separate container.

```bash
container builder status                           # Check builder status
container builder start --cpus 8 --memory 32g      # Start with custom resources
container builder stop                             # Stop the builder
container builder delete                           # Delete the builder
```

## Run Options (Full Reference)

### Process Options
- `-e, --env <key=value>` -- Set environment variables
- `--env-file <path>` -- Read env vars from file
- `-i, --interactive` -- Keep stdin open
- `-t, --tty` -- Allocate TTY
- `-w, --workdir <dir>` -- Set working directory inside container
- `-u, --user <name|uid[:gid]>` -- Set user

### Resource Options
- `-c, --cpus <n>` -- CPU count
- `-m, --memory <size>` -- Memory (supports K, M, G, T, P suffixes)

### Management Options
- `--name <name>` -- Container name
- `-d, --detach` -- Run in background
- `-v, --volume <host:guest>` -- Bind mount
- `-p, --publish <host:guest>` -- Port forwarding
- `--network <name>` -- Attach to network
- `--ssh` -- Forward SSH agent
- `--rosetta` -- Enable Rosetta (x86_64 on ARM)
- `--init` -- Run init process for signal handling
- `--rm, --remove` -- Auto-remove on stop
- `--entrypoint <cmd>` -- Override image entrypoint
- `--read-only` -- Read-only root filesystem
- `--tmpfs <path>` -- Add tmpfs mount

### Registry Options
- `--scheme <http|https|auto>` -- Registry connection scheme

## Common Patterns

### Dev Container with Volume Mount

```bash
container build -f container/dev.Dockerfile -t myapp-dev:latest .
container run -d \
  --name myapp-dev \
  -m 8G \
  -v /path/to/project:/app \
  myapp-dev:latest
container exec myapp-dev sh -c "bun install && bun run dev"
```

### Interactive Debug Shell

```bash
container exec -it myapp-dev sh
```

### Port-Forwarded Service

```bash
container run -d --name api -p 3000:3000 -m 4G myapp:latest
```

### Build and Test in One Shot

```bash
container run --rm -v /path/to/project:/app -w /app oven/bun:1-alpine sh -c "bun install && bun test"
```

### Clean Up Everything

```bash
container kill myapp-dev
container delete myapp-dev
```

## Practical Tips

- Always use `-d` for long-running containers to detach from the process
- Use `--rm` for one-off commands to auto-clean
- Volume mounts are bidirectional and immediate -- no sync delay
- If a container exits immediately, check `container logs <name>` for the exit reason
- The builder shim (`ghcr.io/apple/container-builder-shim/builder`) auto-starts on first build
- For large builds, increase builder resources: `container builder start --cpus 8 --memory 32g`
- Use `--rosetta --arch amd64` when you need x86_64 images on Apple Silicon
- SSH forwarding (`--ssh`) enables git operations inside containers
- Memory is allocated in 1MiB granularity
- `sleep infinity` as CMD keeps a container alive without doing work (useful for dev containers)
