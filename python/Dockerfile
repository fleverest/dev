FROM fleverest/dev:base

WORKDIR /home/dev
COPY --chown=dev:dev Pipfile* .

# Just install global python dependencies.
RUN set -ex && \
    export PATH=$PATH:~/.local/bin && \
    pipenv install --system && \
    nvim --headless +'CocInstall-sync \
      coc-pyright' +qa

WORKDIR /app
