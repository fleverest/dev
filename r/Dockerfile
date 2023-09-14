FROM fleverest/dev:base

WORKDIR /home/dev

RUN set -ex && \
    sudo pacman -Squyy --noconfirm \
      clang clang-tools-extra gcc-fortran make cmake ninja perl \
      libx11 libxt cairo xorg-fonts-100dpi xorg-fonts-75dpi pkg-config \
      libpng libjpeg-turbo libtiff fribidi texlive-core pandoc r && \
    sudo ln -sv "$(whereis clang++)" /lib/cpp

COPY --chown=dev:dev Pipfile* .
COPY --chown=dev:dev .Rprofile .

RUN set -ex && \
    export PATH=$PATH:~/.local/bin && \
    pipenv install && \
    # language servers
    R -e "dir.create(Sys.getenv('R_LIBS_USER'), recursive = TRUE)" && \
    R -e "install.packages('languageserver', repos='https://cran.r-project.org')" && \
    nvim --headless +'CocInstall-sync \
      coc-r-lsp coc-clangd' +qa

WORKDIR /app
