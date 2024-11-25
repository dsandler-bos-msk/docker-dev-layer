ARG from

ARG INTERMEDIATE_INSTALL_PREFIX=/builddir
ARG INSTALL_PREFIX=/usr

FROM ${from} as nvim_builder

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    unzip build-essential cmake git ca-certificates curl gettext && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean -y --no-install-recommends && \
    apt-get autoclean -y --no-install-recommends

ARG INTERMEDIATE_INSTALL_PREFIX
ARG INSTALL_PREFIX

RUN cd /home && \
    git clone --branch=v0.9.4 --depth 1 https://github.com/neovim/neovim && cd neovim && \
    make -j$(nproc) CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=${INTERMEDIATE_INSTALL_PREFIX} && \
    make -j$(nproc) install && \
    cd /home && rm -rf /home/neovim

FROM ${from} as nvim_ide

ARG INTERMEDIATE_INSTALL_PREFIX
ARG INSTALL_PREFIX
ENV VIMPLUG_VERSION=0.11.0

COPY --from=nvim_builder ${INTERMEDIATE_INSTALL_PREFIX} ${INSTALL_PREFIX}

# TODO: merge with below layer yarn only

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl ca-certificates && \
    curl -sL install-node.vercel.app/lts > lts && chmod +x lts && \
    ./lts -y --platform=$(uname -s | tr '[:upper:]' '[:lower:]') && rm lts && \
    curl -fLo /root/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/${VIMPLUG_VERSION}/plug.vim && \
    apt-get remove -y curl && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean -y --no-install-recommends && \
    apt-get autoclean -y --no-install-recommends

# TODO: Split away yarn, git, and ca-certificates. clangd and bear belongs in C layer with ${from} build-arg.

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    clangd git ca-certificates yarn bear && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean -y --no-install-recommends && \
    apt-get autoclean -y --no-install-recommends

# TODO: Add a rust layer with ${from} build-arg

# This should be last tier with ${from} build-arg.

RUN mkdir -p /root/.config/nvim

COPY .vimrc /root/.config/nvim/init.vim
COPY coc-settings.json /root/.config/nvim/

RUN  echo "call plug#begin()" >> /root/.config/nvim/init.vim && \
     echo "Plug 'neoclide/coc.nvim', {'branch': 'release'}" >> /root/.config/nvim/init.vim && \
     echo "call plug#end()" >> /root/.config/nvim/init.vim

RUN  nvim -c ":PlugInstall" "+:qa"
