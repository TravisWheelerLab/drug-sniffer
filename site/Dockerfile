FROM python:3.9-slim-bullseye

RUN apt-get update && apt-get -y install \
        make \
    && rm -rf /var/lib/apt/lists/*

RUN pip install sphinx==4.4.0

VOLUME /data
WORKDIR /data
