FROM nvidia/cuda:9.2-cudnn7-devel-ubuntu18.04

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -yq dist-upgrade \
 && apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    sudo \
    locales \
    fonts-liberation \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Install Tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.10.0/tini && \
    echo "1361527f39190a7338a0b434bd8c88ff7233ce7b9a4876f3315c22fce7eca1b0 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

# Configure environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=jovyan \
    NB_UID=1000 \
    NB_GID=100 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
ENV PYSPARK_PYTHON python3
ENV PYSPARK_DRIVER_PYTHON python3
ENV R_LIBS_USER $SPARK_HOME/R/lib

# Spark config
COPY spark/spark-defaults.conf /usr/local/spark/conf/spark-defaults.conf

RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
    curl \
    lsb-release \
    gnupg2 \
    apt-utils && \
    rm -rf /var/lib/apt/lists/*

# GCloud
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# R pre-requisites
RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
    ssh \
    vim \
    libapparmor1 \
		libedit2 \
		psmisc \
		libssl1.0.0 \
    awscli \
    dnsutils \
    wget \
    fonts-dejavu \
    tzdata \
    gfortran \
    gcc \
    libjq-dev \
    libv8-3.14-dev \
    protobuf-compiler \
    libprotobuf-dev \
    libudunits2-dev \
    libgdal-dev \
    libgdal20 \
    libgeos-dev \
    google-cloud-sdk \
    zlib1g-dev \
    libjpeg-dev \
    cmake \
    swig \
    libboost-all-dev \
    libsdl2-dev \
    libosmesa6-dev \
    patchelf \
    ffmpeg \
    xvfb && \
    rm -rf /var/lib/apt/lists/*

###
### Swift
###
ENV SWIFT_VERSION RELEASE-0.3.1
RUN mkdir -p /opt/swift && \
   cd /opt/swift && \
   apt update -y && \
   apt install -y clang libcurl3 libicu-dev libpython-dev libncurses5-dev libblocksruntime-dev && \
   wget https://storage.googleapis.com/swift-tensorflow-artifacts/releases/v0.3.1/rc1/swift-tensorflow-$SWIFT_VERSION-cuda9.2-cudnn7-ubuntu18.04.tar.gz && \
   tar -vxzf swift-tensorflow-$SWIFT_VERSION-cuda9.2-cudnn7-ubuntu18.04.tar.gz && \
   rm *.tar.gz



##
## CONDA
##

ADD fix-permissions /usr/local/bin/fix-permissions
# Create jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    chmod g+w /etc/passwd /etc/group && \
    fix-permissions $HOME && \
    fix-permissions $CONDA_DIR

USER $NB_UID

# Setup work directory for backward-compatibility
RUN mkdir /home/$NB_USER/work && \
    fix-permissions /home/$NB_USER

# Install conda as jovyan and check the md5 sum provided on the download site
ENV MINICONDA_VERSION 4.3.30
RUN cd /tmp && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "0b80a152332a4ce5250f3c09589c7a81 *Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda config --system --prepend channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
    $CONDA_DIR/bin/conda config --system --set show_channel_urls true && \
    $CONDA_DIR/bin/conda update --all --quiet --yes && \
    conda clean -tipsy && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

##
## PYTHON
##

# Install extra python libs
COPY python3/conda-requirements.txt /tmp/python3/conda-requirements.txt

# Conda packages
RUN conda install --yes \
    -c blazingdb -c nvidia -c rapidsai -c numba -c conda-forge -c defaults \
    --file /tmp/python3/conda-requirements.txt && \
    conda clean -tipsy

# OpenAI GYM package
USER root
RUN apt-get install -y git
USER $NB_USER
WORKDIR $HOME
RUN git clone https://github.com/openai/gym.git && \
    cd gym && \
    pip install -e . && \
    cd .. && \
    rm -Rf gym

# PIP packages
COPY python3/pip-requirements.txt /tmp/python3/pip-requirements.txt
RUN pip install -r /tmp/python3/pip-requirements.txt


###
### R
###

# R packages
COPY R/r-requirements.txt /tmp/r-requirements.txt
RUN conda install --yes -c r --file /tmp/r-requirements.txt && \
    conda clean -tipsy

# COPY R/install.R /tmp/install.R
# RUN Rscript --slave --no-save --no-restore-history /tmp/install.R
