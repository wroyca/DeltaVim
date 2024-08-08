# TRY docker build -t deltavim:latest .
#       && docker run --rm -it deltavim:latest
# OR  docker build --target=base -t neovim:alpine-latest
#       && docker run --rm -it -v $PWD:/root/.config/nvim neovim:alpine-latest

FROM alpine:3.20 AS base

RUN apk add --no-cache --update \
    neovim~=0.10 \
    alpine-sdk \
    git \
    ripgrep

ENTRYPOINT ["nvim"]

FROM base AS deltavim

COPY . /root/.config/nvim
