ARG from

ARG INTERMEDIATE_INSTALL_PREFIX=/builddir
ARG INSTALL_PREFIX=/usr

FROM ${from} as nvim_builder
USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    unzip build-essential cmake git ca-certificates curl gettext && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean -y --no-install-recommends && \
    apt-get autoclean -y --no-install-recommends

ARG INTERMEDIATE_INSTALL_PREFIX
ARG INSTALL_PREFIX

RUN cd /home && \
    git clone --branch=v0.11.2 --depth 1 https://github.com/neovim/neovim && cd neovim && \
    make -j$(nproc) CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_GENERATOR="Unix\ Makefiles" CMAKE_INSTALL_PREFIX=${INTERMEDIATE_INSTALL_PREFIX} && \
    make -j$(nproc) CMAKE_GENERATOR="Unix\ Makefiles" install && \
    cd /home && rm -rf /home/neovim

FROM ${from} as nvim_ide_base
USER root

ARG INTERMEDIATE_INSTALL_PREFIX
ARG INSTALL_PREFIX
ENV VIMPLUG_VERSION=0.14.0

COPY --from=nvim_builder ${INTERMEDIATE_INSTALL_PREFIX} ${INSTALL_PREFIX}

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl ca-certificates git ca-certificates yarn && \
    curl -sL install-node.vercel.app/lts > lts && chmod +x lts && \
    ./lts -y --platform=$(uname -s | tr '[:upper:]' '[:lower:]') && rm lts && \
    curl -fLo /root/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/${VIMPLUG_VERSION}/plug.vim && \
    apt-get remove -y curl && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean -y --no-install-recommends && \
    apt-get autoclean -y --no-install-recommends
