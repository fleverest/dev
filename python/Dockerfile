FROM fleverest/dev:base

WORKDIR /root

COPY Pipfile* .

# Just install global python dependencies.
RUN set -ex && \
    pipenv install --system

WORKDIR /app
