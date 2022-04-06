FROM debian:bullseye-slim

# -------------------
# System Dependencies
# -------------------

RUN apt-get update && apt-get -y install \
        coreutils \
        openbabel \
        procps \
        unzip \
    && rm -rf /var/lib/apt/lists/*

# Python

WORKDIR /opt

ADD https://repo.anaconda.com/miniconda/Miniconda3-py38_4.10.3-Linux-x86_64.sh miniconda.sh
RUN chmod +x miniconda.sh \
    && ./miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh
ENV PATH=/opt/miniconda3/bin/:${PATH}

RUN conda install -y -c conda-forge rdkit rdkit=2020.03.1 \
    && conda install -y numpy numpy=1.18.1 \
    && conda install -y scipy scipy=1.4.1 \
    && pip install matplotlib==3.2.1 \
    && pip install func_timeout==4.3.5


# dedup.py

WORKDIR /opt

RUN mkdir bin
COPY deps/dedup.py bin/dedup.py
ENV PATH=${PATH}:/opt/bin

# autodock vina

WORKDIR /opt

ARG AD_NAME=autodock_vina_1_1_2_linux_x86
ARG AD_FILE=${AD_NAME}.tgz

COPY deps/${AD_FILE} ${AD_FILE}
RUN tar xfz ${AD_FILE} \
    && rm ${AD_FILE} \
    && mv ${AD_NAME} autodock_vina
ENV PATH=${PATH}:/opt/autodock_vina/bin

# autogrow4

WORKDIR /opt

ARG AG_NAME=autogrow4-4.0.3
ARG AG_FILE=${AG_NAME}.zip

COPY deps/${AG_FILE} ${AG_FILE}
RUN unzip ${AG_FILE} \
    && rm ${AG_FILE} \
    && mv ${AG_NAME} autogrow4
COPY deps/run.sh autogrow4/
ENV PATH=${PATH}:/opt/autogrow4

COPY deps/Fragment_MW_up_to_250.smi /opt/autogrow4/
ENV SOURCE_COMPOUND_FILE="/opt/autogrow4/Fragment_MW_up_to_250.smi"
ENV NUMBER_OF_PROCESSORS=12

# ---------------------
# Runtime configuration
# ---------------------

VOLUME /data
WORKDIR /data

