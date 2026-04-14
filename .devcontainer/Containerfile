FROM ocaml/opam:debian-12-ocaml-5.2

USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential m4 pkg-config libssl-dev ca-certificates git curl wget \
    && rm -rf /var/lib/apt/lists/*

USER opam
SHELL ["/bin/bash", "-lc"]
RUN opam update && \
    eval "$(opam env)" && \
    opam install -y dune ocaml-lsp-server merlin utop

WORKDIR /workspace
CMD ["/bin/bash"]
