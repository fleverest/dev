# My Development Environment

This repo builds a container with my full development environment, including git
configured using specified SSH keys and neovim with various plugins and language
servers. It is based on the `node` container, and it includes python builds R
from source.

I highly recommend [running this container
rootless](https://rootlesscontaine.rs).

## Building the image(s)

This repository defines images for various development environments. To build
any of these images, you'll first need to build the base image. To do so, place
one SSH key (public and private key) in the `base/.ssh/` directory. This SSH key
should ideally be known to and trusted by your remotes. For example, if you
work on GitHub, you can navigate to `Account > Settings > SSH and GPG keys`
and add the public key as a new "SSH Key" (and optionally as a "signing key"
to verify your commits). Then pass your name and email as build arguments to
configure git inside the container:

```bash
docker build \
    -t fleverest/dev:base
    --build-arg NAME="Full Name" \
    --build-arg EMAIL="your@email.address" \
    base/
```

Then you can build any of the other development enviroments, for example my
R environment:

```base
docker build \
    -t fleverest/dev:r \
    r/
```

## Using the container(s)

You may need to edit the permissions for the directory to provide write access
to the container user. In Podman you can do the following:

```bash
podman unshare chmod -R $UID:$UID .
```

To use the container, you will need to mount your working directory to `/app` in
the container:

```bash
docker run -it --rm -v .:/app fleverest/dev:base
```

I suggest making aliases for this, for example:

```bash
alias dev="docker run -it --rm -v .:/app fleverest/dev:base"`
```

If you want to take advantage of caching, for example to persist R libraries
between sessions, you will need to make use of volumes:

```bash
docker run -it --rm -v .:/app -v r:/usr/lib/R/library fleverest/dev:r
```

You can also pass your X11 session through by adding the `$DISPLAY` environment
variable and attaching the `/tmp/.X11-unix` directory as a volume:

```bash
docker run \
    -it \
    --rm \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY \
    fleverest/dev:r
```
