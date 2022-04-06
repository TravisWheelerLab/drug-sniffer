FROM debian:bullseye-slim as build

RUN apt-get update && apt-get -y install \
        gcc \
        procps \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
COPY deps/neighbors.c .
RUN gcc -mtune=native -march=native -Wall -Wextra -o neighbors neighbors.c

FROM debian:bullseye-slim

# -------------------
# System Dependencies
# -------------------

RUN apt-get update && apt-get -y install \
        procps \
        python3 \
        python3-pip \
        python3-rdkit \
        python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/fingerprinting

COPY deps/similarity.py /opt/fingerprinting/
COPY deps/run.sh /opt/fingerprinting/
COPY --from=build /opt/neighbors /opt/fingerprinting/

ENV PATH=${PATH}:/opt/fingerprinting

ENV TANIMOTO_CUTOFF=0.5

# ---------------------
# Runtime configuration
# ---------------------

VOLUME /data
WORKDIR /data
