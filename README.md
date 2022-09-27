# Container-neovim

This repo builds a container with a basic dev environment, including git
configured using your SSH key and neovim with various plugins and language servers.


I highly recommend using `podman` over `docker`, otherwise you should configure
a non-root user in the Dockerfile.

## Building the image

To build the image, you'll need to:

1. Place your public and private SSH keys in the `.ssh/` directory.
2. Build the container while providing two git configuration arguments:

```bash
docker build \
  --build-arg NAME="Floyd Everest" \
  --build-arg EMAIL="me@floydeverest.com" \
  -t nvim .
```

## Using the container

To use the container, you can simply mount your working directory to `/app` in
the container:

```bash
docker run -it --rm -v .:/app nvim
```
