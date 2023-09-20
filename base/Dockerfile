# This stage builds neovim
FROM archlinux:latest as build_nvim

RUN set -ex && \
    pacman -Squyy --noconfirm \
      git \
      clang \
      make \
      cmake \
      pkgconf \
      libtool \
      unzip && \
    cd $(mktemp -d) && \
    git clone https://github.com/neovim/neovim . \
      -b stable --single-branch --depth 1 && \
    make CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make install

# This stage sets up the neovim plugins and developer environment
FROM archlinux:latest

ENV XDG_DATA_HOME=/home/dev/.config

# Copy neovim from build stage
COPY --from=build_nvim /usr/local/ /usr/local/

COPY entrypoint /entrypoint

RUN set -ex && \
    # Configure system dependencies and add dev user
    pacman -Squyy --noconfirm \
      # Node for coc.nvim
      nodejs-lts-hydrogen yarn \
      # Python dependencies
      pyenv python-pip python-pipx python-pre-commit \
      # Shell and other tools
      zsh tree ripgrep which mcfly git keychain sudo openssh tmux less && \
    chmod +x /entrypoint && \
    useradd -m -G wheel dev && \
    sed -i /etc/sudoers -e "/^# %wheel /s/^# //g"

USER dev

WORKDIR /home/dev
COPY --chown=dev:dev .config .config
COPY --chown=dev:dev .ssh .ssh
COPY --chown=dev:dev .zshrc .zshrc
COPY --chown=dev:dev .tmux.conf .tmux.conf

ARG NAME
ARG EMAIL

RUN set -ex && \
    export PATH=$PATH:/home/dev/.local/bin && \
    # Install vim-plug and load plugins
    curl -fLo ~/.config/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    nvim --headless +PlugInstall +qa && \
    # Install some basic coc-nvim language servers
    nvim --headless +'CocInstall \
        coc-json coc-sh coc-markdownlint coc-html coc-docker' +qa && \
    # Configure git
    pwd && \
    ls -a && \
    git config --global commit.gpgsign true && \
    git config --global gpg.format ssh && \
    git config --global \
      user.signingkey "$(ls -d ~/.ssh/*.pub | head -n1 | cat)" && \
    git config --global user.name "$NAME" && \
    git config --global user.email "$EMAIL" && \
    git config --global core.editor "nvim" && \
    # Install antigen for zsh config
    curl -L git.io/antigen > /home/dev/antigen.zsh && \
    touch .zsh_history && \
    zsh -c "source /home/dev/.zshrc"

WORKDIR /app
ENTRYPOINT ["/entrypoint"]
CMD ["zsh"]
