ARG from

ARG INTERMEDIATE_INSTALL_PREFIX=/builddir
ARG INSTALL_PREFIX=/usr

FROM ${from} as nvim_ide_rust
USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl && \
    curl https://sh.rustup.rs -sSf | bash -s -- -y && \
    apt-get remove -y curl && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean -y --no-install-recommends && \
    apt-get autoclean -y --no-install-recommends
ENV PATH="$PATH:/root/.cargo/bin"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl && \
    mkdir -p /root/.local/bin && \
    curl -L https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz \
    | gunzip -c - > ~/.local/bin/rust-analyzer && \
    chmod +x ~/.local/bin/rust-analyzer && \
    apt-get remove -y curl && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean -y --no-install-recommends && \
    apt-get autoclean -y --no-install-recommends
ENV PATH="$PATH:/root/.local/bin"

RUN rustup component add rust-analyzer
