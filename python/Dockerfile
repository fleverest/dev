FROM fleverest/dev:base

WORKDIR /home/dev

# Just install global python dependencies.
RUN set -ex && \
    export PATH=$PATH:~/.local/bin && \
    sudo pacman -Squyy --noconfirm clang make cmake pyenv && \
    nvim --headless +'CocInstall-sync \
      coc-pyright' +qa

WORKDIR /app
