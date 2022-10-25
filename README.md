# My Development Environment

This repo builds a container with my full development environment, including git
configured using specified SSH keys and neovim with various plugins and language
servers. It is based on the `node` container, and it includes python builds R
from source.

I highly recommend [running this container
rootless](https://rootlesscontaine.rs).

## Building the image

To build the image, you'll need to place your public and private SSH key in the
`.ssh/` directory. This SSH key should ideally be known to and trusted by your
remote. For example, in GitHub you should navigate to
`Account > Settings > SSH and GPG keys` and add the public key as a new
"SSH Key" and "signing key". Then, pass your name and email to configure git
inside the container:

```bash
docker build \
  --build-arg NAME="Full Name" \
  --build-arg EMAIL="your@email.address" \
  -t dev .
```

## Using the container

To use the container, you can simply mount your working directory to `/app` in
the container:

```bash
docker run -it --rm -v .:/app dev
```

You could create an alias for this, for example:

```bash
alias dev="docker run -it --rm -v .:/app dev"`
```

If you want to take advantage of caching, for example to cache R packages
between sessions, you will need to make use of volumes:

```bash
docker run -it --rm -v .:/app -v r:/usr/lib/R/library dev
```

## Neovim

I have included a very opinionated neovim configuration. It consists of many
[coc](https://github.com/neoclide/coc.nvim) language servers and other plugins.
