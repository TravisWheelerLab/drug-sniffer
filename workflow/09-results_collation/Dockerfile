FROM debian:bullseye-slim

RUN apt-get update && apt-get -y install \
        python3 \
        python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN mkdir scripts
COPY deps/process_results.py scripts/

ENV PATH=${PATH}:/opt/scripts

VOLUME /data
WORKDIR /data
