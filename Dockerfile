FROM alpine:latest AS build_nvim

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

RUN git clone https://github.com/neovim/neovim && \
    cd neovim && \
    make CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make install

FROM node:18-alpine

ENV XDG_DATA_HOME=/root/.config

ARG NAME
ARG EMAIL

COPY --from=build_nvim /usr/local/bin/nvim /usr/local/bin/nvim
COPY --from=build_nvim /usr/local/share/nvim /usr/local/share/nvim
COPY --from=build_nvim /usr/local/lib/nvim /usr/local/lib/nvim

RUN apk add --update --no-cache \
    clang clang-extra-tools \
    python3 py3-pip \
    git \
    curl \
    openssh-client \
    gpg gpg-agent && \
    rm -rf /root/.gnupg /root/.ssh

WORKDIR /root

COPY Pipfile* .
COPY .config .config
RUN pip install -U pip && \
    pip install pipenv && \
    pipenv install && \
    nvim --headless +PlugInstall +qa && \
    nvim --headless +'CocInstall -sync \
        coc-json coc-clangd coc-css coc-sh \
        coc-markdownlint coc-tsserver coc-html \
        coc-vetur coc-pyright coc-docker' +qa

COPY --chmod=700 .ssh .ssh

# Configure git
RUN git config --global commit.gpgsign true && \
    git config --global gpg.format ssh && \
    git config --global user.signingkey "$(cat .ssh/*.pub)" && \
    git config --global user.name "$NAME" && \
    git config --global user.email "$EMAIL"

WORKDIR /app

CMD ["nvim"]
