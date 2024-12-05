ARG from

ARG INTERMEDIATE_INSTALL_PREFIX=/builddir
ARG INSTALL_PREFIX=/usr

FROM ${from} as nvim_ide_rust
USER root

# TODO: Add a rust layer with ${from} build-arg
RUN echo rust > /rust.txt
