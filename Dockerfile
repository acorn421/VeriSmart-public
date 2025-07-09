FROM ubuntu:20.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    opam \
    m4 \
    pkg-config \
    libgmp-dev \
    zlib1g-dev \
    wget \
    curl \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Initialize opam and install OCaml with num package
RUN opam init --disable-sandboxing -y && \
    eval $(opam env) && \
    opam install -y conf-m4.1 ocamlfind ocamlbuild num yojson batteries ocamlgraph zarith

# Install Z3
RUN eval $(opam env) && \
    wget https://github.com/Z3Prover/z3/releases/download/z3-4.7.1/z3-4.7.1.tar.gz && \
    tar -xvzf z3-4.7.1.tar.gz && \
    cd z3rel && \
    python3 scripts/mk_make.py --ml && \
    cd build && \
    make -j 4 && \
    make install && \
    cd / && \
    rm -rf z3-4.7.1.tar.gz z3rel

# Install Solidity compiler
RUN curl -fsSL https://github.com/ethereum/solidity/releases/download/v0.5.11/solc-static-linux -o /usr/local/bin/solc && \
    chmod +x /usr/local/bin/solc

# Set working directory
WORKDIR /app

# Copy VeriSmart source code
COPY . .

# Make build script executable and build VeriSmart
RUN chmod +x build && \
    eval $(opam env) && \
    ./build

# Set entry point
ENTRYPOINT ["/bin/bash"]