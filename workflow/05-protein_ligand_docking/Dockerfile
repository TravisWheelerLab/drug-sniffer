FROM debian:bullseye-slim

# -------------------
# System Dependencies
# -------------------

RUN apt-get update && apt-get -y install \
        openbabel \
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

# script

COPY deps/autodock.sh /opt/protein_ligand_docking/
ENV PATH=${PATH}:/opt/protein_ligand_docking

ENV NUMBER_OF_POSES=4

# ---------------------
# Runtime configuration
# ---------------------

VOLUME /data
WORKDIR /data

