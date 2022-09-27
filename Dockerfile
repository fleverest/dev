# This stage builds neovim
FROM alpine:latest AS build_nvim

# Install build dependencies
RUN apk add --update --no-cache \
    git \
    build-base \
    cmake \
    automake \
    autoconf \
    libtool \
    pkgconf \
    coreutils \
    curl \
    unzip \
    gettext-tiny-dev

# Clone neovim and install latest version
RUN git clone https://github.com/neovim/neovim && \
    cd neovim && \
    make CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make install


# This stage sets up the neovim plugins and developer environment
FROM node:18-alpine

ARG NAME
ARG EMAIL

ENV XDG_DATA_HOME=/root/.config

# Copy neovim from build stage
COPY --from=build_nvim /usr/local/bin/nvim /usr/local/bin/nvim
COPY --from=build_nvim /usr/local/share/nvim /usr/local/share/nvim
COPY --from=build_nvim /usr/local/lib/nvim /usr/local/lib/nvim

WORKDIR /root

COPY Pipfile* .
COPY .config .config
COPY .ssh .ssh
COPY entrypoint /entrypoint

RUN set -ex && \
    # Install neovim plugin dependencies
    apk add --update --no-cache \
    clang clang-extra-tools \
    python3 py3-pip \
    git \
    curl \
    openssh-client && \
    rm -rf /root/.ssh && \
    # Install pipenv and install python dependencies
    pip install -U pip && \
    pip install pipenv && \
    pipenv install && \
    # Install vim-plug and load plugins
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    nvim --headless +PlugInstall +qa && \
    # Install coc-nvim language servers
    nvim --headless +'CocInstall -sync \
        coc-json coc-clangd coc-css coc-sh \
        coc-markdownlint coc-tsserver coc-html \
        coc-vetur coc-pyright coc-docker' +qa && \
    # Configure git
    git config --global commit.gpgsign true && \
    git config --global gpg.format ssh && \
    git config --global user.signingkey "$(ls .ssh/*.pub | head -n1 | cat)" && \
    git config --global user.name "$NAME" && \
    git config --global user.email "$EMAIL" && \
    chmod +x /entrypoint

WORKDIR /app

ENTRYPOINT ["/entrypoint"]

CMD ["nvim"]
