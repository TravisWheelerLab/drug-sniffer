FROM debian:bullseye-slim

# -------------------
# System Dependencies
# -------------------

RUN apt-get update && apt-get -y install \
        openbabel \
        python \
    && rm -rf /var/lib/apt/lists/*

# autodock vina

WORKDIR /opt

ARG AD_NAME=autodock_vina_1_1_2_linux_x86
ARG AD_FILE=${AD_NAME}.tgz

COPY deps/${AD_FILE} ${AD_FILE}
RUN tar xfz ${AD_FILE} \
    && rm ${AD_FILE} \
    && mv /opt/${AD_NAME} autodock_vina
ENV PATH=${PATH}:/opt/autodock_vina/bin

# mgltools

WORKDIR /opt

# MGLTools 1.5.7
ARG MGL_URL=https://ccsb.scripps.edu/download/532/
ARG MGL_NAME=mgltools_x86_64Linux2_1.5.7

ADD ${MGL_URL} mgltools.tar.gz
RUN tar xfz mgltools.tar.gz \
    && mv ${MGL_NAME} mgltools \
    && cd mgltools \
    && ./install.sh

# script

COPY deps/run.sh /opt/protein_ligand_docking/
ENV PATH=${PATH}:/opt/protein_ligand_docking

# ---------------------
# Runtime configuration
# ---------------------

VOLUME /data
WORKDIR /data

