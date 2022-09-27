# Container-neovim

This repo builds a container with a basic dev environment, including git
configured using your SSH key and neovim with various plugins and language
servers.

I highly recommend using `podman` over `docker`, otherwise you should
configure a non-root user in the Dockerfile.

## Building the image

To build the image, you'll need to place your public and private SSH key in the
`.ssh/` directory. This SSH key should ideally be known to and trusted by your
remote. For example, in GitHub you should navigate to
`Account > Settings > SSH and GPG keys` and add the public key as a new
`SSH Key` and signing key. Then, pass your name and email to configure git
inside the container:

```bash
docker build \
  --build-arg NAME="Full Name" \
  --build-arg EMAIL="your@email.address" \
  -t nvim .
```

## Using the container

To use the container, you can simply mount your working directory to `/app` in
the container:

```bash
docker run -it --rm -v .:/app nvim
```

You could create an alias for this, for example:

```bash
alias nvim="docker run -it -v .:/app --rm nvim"`
```

Then, you could start a neovim session by running `nvim`. However, you wouldn't
be able to pass filenames as arguments this way. You'd need to navigate to the
file using the pre-configured [nerdtree](https://github.com/preservim/nerdtree)
browser.
