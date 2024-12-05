ARG from

FROM ${from} as nvim_ide_final
USER root

RUN mkdir -p /root/.config/nvim

COPY .vimrc /root/.config/nvim/init.vim
COPY coc-settings.json /root/.config/nvim/

RUN  echo "call plug#begin()" >> /root/.config/nvim/init.vim && \
     echo "Plug 'neoclide/coc.nvim', {'branch': 'release'}" >> /root/.config/nvim/init.vim && \
     echo "call plug#end()" >> /root/.config/nvim/init.vim

RUN  nvim -c ":PlugInstall" "+:qa"
