## Running

Add the `docker-layer` command to you shell by entering the following command while in the directory of this repo:

    $ source bash_aliases

## Running

To build a container overtop of `<base-container>` with a C/C++ dev environment, run:

    $ docker-layer nvim <container-tag> cpp

To build a container overtop of `<base-container>` with a Rust dev environment, run:

    $ docker-layer nvim <container-tag> cpp

To build a container overtop of `<base-container>` with both a C/C++ and Rust dev environment, run:

    $ docker-layer nvim <container-tag> cpp rust

These language arguments can be specified in any order and as many as long as the language is currently supported. Currently only C/C++ and Rust are supported.
