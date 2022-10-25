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
    gettext-tiny-dev && \
    git clone https://github.com/neovim/neovim && \
    cd neovim && \
    make CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make install

# This stage builds R
FROM alpine:latest as build_r

ENV R_VERSION=4.2.1

# Install build dependencies
RUN apk add --update --no-cache \
    clang libc-dev libstdc++ gfortran make curl curl-dev \
    libx11-dev libxt-dev zlib zlib-dev bzip2 bzip2-dev xz-dev pcre2 pcre2-dev \
    cairo-dev libpng-dev jpeg-dev tiff-dev readline-dev texlive && \
    ln -sv "$(which clang++)" /lib/cpp

WORKDIR /tmp/R

RUN curl -O https://cran.rstudio.com/src/base/R-4/R-${R_VERSION}.tar.gz && \
    tar -xzvf R-${R_VERSION}.tar.gz && \
    cd R-${R_VERSION} && \
    CFLAGS="-std=gnu99 -Wall -pedantic" \
    CXXFLAGS="-Wall -pedantic" \
    CC="clang" \
    CXX="clang++" \
    ./configure \
      --prefix=/usr \
      --enable-memory-profiling \
      --enable-R-shlib \
      --enable-R-static-lib \
      --with-recommended-packages \
      --with-blas \
      --with-lapack && \
    make && \
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

# Copy R from build stage
COPY --from=build_r /usr/bin/R /usr/bin/R
COPY --from=build_r /usr/bin/Rscript /usr/bin/Rscript
COPY --from=build_r /usr/share/man/man1 /usr/share/man/man1
COPY --from=build_r /usr/share/man/man1 /usr/share/man/man1
COPY --from=build_r /usr/lib/R /usr/lib/R

WORKDIR /root

COPY Pipfile* .
COPY .config .config
COPY .ssh .ssh
COPY .zshrc .zshrc
COPY entrypoint /entrypoint

RUN set -ex && \
    # Install neovim plugin dependencies
    apk add --update --no-cache \
      # C/C++
      clang clang-extra-tools libc-dev libstdc++ \
      # R dependencies
      gfortran libxt libintl tiff cairo texlive \
      # make/cmake/ninja for managing C/C++ projects
      make cmake ninja \
      # Python
      python3 py3-pip \
      # Shell and other tools
      zsh tree ripgrep mcfly git curl openssh-client && \
    # Install pipenv and python packages
    pip install -U pip pipenv && \
    pipenv install --system && \
    # Install vim-plug and load plugins
    curl -fLo ~/.config/nvim/site/autoload/plug.vim --create-dirs \
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
    git config --global \
      user.signingkey "~/$(ls -d .ssh/*.pub | head -n1 | cat)" && \
    git config --global user.name "$NAME" && \
    git config --global user.email "$EMAIL" && \
    # Install antigen for zsh config
    curl -L git.io/antigen > /root/antigen.zsh && \
    touch .zsh_history && \
    zsh -c "source /root/.zshrc" && \
    chmod +x /entrypoint

WORKDIR /app

ENTRYPOINT ["/entrypoint"]

CMD ["zsh"]
