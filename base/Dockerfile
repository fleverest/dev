# This stage builds neovim
FROM archlinux:latest as build_nvim

RUN set -ex && \
    pacman -Squyy --noconfirm \
      git \
      clang \
      make \
      cmake \
      pkgconf \
      unzip && \
    cd $(mktemp -d) && \
    git clone https://github.com/neovim/neovim . \
      -b master --single-branch --depth 1 && \
    make CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make install

# This stage sets up the neovim plugins and developer environment
FROM archlinux:latest

ARG NAME
ARG EMAIL

ENV XDG_DATA_HOME=/root/.config

# Copy neovim from build stage
COPY --from=build_nvim /usr/local/ /usr/local/

WORKDIR /root

COPY Pipfile* .
COPY .config .config
COPY .ssh .ssh
COPY .zshrc .zshrc
COPY entrypoint /entrypoint

RUN set -ex && \
    # Install neovim plugin dependencies
    pacman -Squyy --noconfirm \
      # Node for coc.nvim
      nodejs-lts-hydrogen yarn \
      # Python dependencies
      python-pip \
      # Shell and other tools
      zsh tree ripgrep mcfly git openssh && \
    # Install pipenv and python packages
    pip install -U pip pipenv && \
    pipenv install --system && \
    # Install vim-plug and load plugins
    curl -fLo ~/.config/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    nvim --headless +PlugInstall +qa && \
    # Install some basic coc-nvim language servers
    nvim --headless +'CocInstall -sync \
        coc-json coc-sh coc-markdownlint coc-html coc-docker' +qa && \
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
