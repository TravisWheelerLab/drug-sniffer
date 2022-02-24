# ========
# DLIGAND2
# ========

FROM debian:bullseye-slim AS build-dligand2

RUN apt-get update && apt-get -y install \
        unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

COPY deps/dligand2.zip ./
RUN unzip dligand2.zip \
    && mv DLIGAND2-* DLIGAND2

# ==========
# Main Image
# ==========

FROM debian:bullseye-slim

# -------------------
# System Dependencies
# -------------------

RUN apt-get update && apt-get -y install \
        openbabel \
        openjdk-11-jre-headless \
        python3 \
        python3-numpy \
        python3-torch \
        python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/activity_prediction

# autodock vina

WORKDIR /opt

ARG AD_NAME=autodock_vina_1_1_2_linux_x86
ARG AD_FILE=${AD_NAME}.tgz

COPY deps/${AD_FILE} ${AD_FILE}
RUN tar xfz ${AD_FILE} \
    && rm ${AD_FILE} \
    && mv /opt/${AD_NAME} autodock_vina
ENV PATH=${PATH}:/opt/autodock_vina/bin

# dligand2 / dfire

WORKDIR /opt

RUN mkdir DLIGAND2
COPY --from=build-dligand2 /opt/DLIGAND2 ./DLIGAND2/

ENV DATADIR=/opt/DLIGAND2/bin
ENV PATH=${PATH}:/opt/DLIGAND2/bin

# smina

WORKDIR /opt

COPY deps/smina.static activity_prediction/
COPY deps/allterms activity_prediction/

# run script

WORKDIR /opt

COPY deps/run.sh activity_prediction/

# prediction model

WORKDIR /opt

COPY deps/rescore.py activity_prediction/
COPY deps/platstd.h5 activity_prediction/

# ---------------------
# Runtime configuration
# ---------------------

ENV PATH=${PATH}:/opt/activity_prediction

VOLUME /data
WORKDIR /data

