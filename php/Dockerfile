from fleverest/dev:base

RUN set -ex && \
    yarn global add intelephense && \
    nvim --headless +'CocInstall -sync \
      coc-phpls' +qa

WORKDIR /app
