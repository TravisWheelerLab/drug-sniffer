FROM debian:bullseye-slim

RUN apt-get update && apt-get -y install \
        git \
        gnupg \
        openjdk-11-jdk-headless \
        openjdk-11-jre-headless \
    && rm -rf /var/lib/apt/lists/*

ARG R_REPO="deb http://cloud.r-project.org/bin/linux/debian bullseye-cran40/"
RUN apt-key adv --keyserver keyserver.ubuntu.com \
        --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' \
    && echo "${R_REPO}" > /etc/apt/sources.list.d/r_cran.list \
    && apt-get update \
    && apt-get -y install \
        r-base \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone https://gitlab.com/vishsoft/fpadmet.git \
    && cd fpadmet \
    && chmod 777 RESULTS \
    && git checkout d61d63e3d3c37e887a5d4b1959260d9f1b41f77a

WORKDIR /opt/fpadmet
RUN bash installpackages.sh ranger \
    && bash installpackages.sh caret \
    && bash installpackages.sh quantregForest \
    && bash installpackages.sh randomForest \
    && chmod +x runadmet.sh

ENV PATH=${PATH}:/opt/fpadmet

WORKDIR /opt
RUN mkdir admet_filtering

WORKDIR /opt/admet_filtering
COPY deps/JLogP.jar ./
COPY deps/run.sh ./

ENV PATH=${PATH}:/opt/admet_filtering

VOLUME /data
WORKDIR /data

