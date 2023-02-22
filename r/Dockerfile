# This stage builds R
FROM fleverest/dev:base

ENV R_VERSION=4.2.2

USER root
WORKDIR /tmp/R

RUN set -ex && \
    pacman -Squyy --noconfirm \
      clang clang-tools-extra which gcc-fortran make cmake ninja perl \
      libx11 libxt cairo xorg-fonts-100dpi xorg-fonts-75dpi pkg-config \
      libpng libjpeg-turbo libtiff fribidi texlive-core && \
    ln -sv "$(whereis clang++)" /lib/cpp && \
    curl -O https://cran.rstudio.com/src/base/R-4/R-${R_VERSION}.tar.gz && \
    tar -xzvf R-${R_VERSION}.tar.gz && \
    cd R-${R_VERSION} && \
    CC="clang" \
    CXX="clang++" \
    CXX11="clang++" \
    CFLAGS="-std=gnu99 -Wall -pedantic" \
    CXXFLAGS="-Wall -pedantic" \
    LIBS="-lz -lbz2 -llzma" \
    ./configure \
      --prefix="/usr/local" \
      --enable-R-shlib \
      --with-recommended-packages && \
    make -j 4 && \
    make install && \
    cd / && \
    rm -rf /tmp/R

USER dev
WORKDIR /home/dev
COPY --chown=dev:dev Pipfile* .
COPY --chown=dev:dev .Rprofile .

RUN set -ex && \
    export PATH=$PATH:~/.local/bin && \
    pipenv install --system && \
    # language servers
    R -e "dir.create(Sys.getenv('R_LIBS_USER'), recursive = TRUE)" && \
    R -e "install.packages('languageserver', repos='https://cran.r-project.org')" && \
    nvim --headless +'CocInstall -sync \
      coc-r-lsp coc-clangd' +qa

WORKDIR /app
