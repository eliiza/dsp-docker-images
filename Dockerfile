ARG BASE_CONTAINER=jupyter/pyspark-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Ray Hilton <ray.hilton@eliiza.com.au>"

# Setup Env
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
ENV PYSPARK_PYTHON python3
ENV PYSPARK_DRIVER_PYTHON python3
ENV R_LIBS_USER $SPARK_HOME/R/lib

USER root

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
    google-cloud-sdk && \
    rm -rf /var/lib/apt/lists/*

RUN fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    fix-permissions $R_LIBS_USER && \
    fix-permissions /home/$NB_USER/.conda/

USER $NB_UID

# R packages
COPY R/r-requirements.txt /tmp/r-requirements.txt
RUN conda install --yes -c r --file /tmp/r-requirements.txt && \
    conda clean -tipsy

# COPY R/install.R /tmp/install.R
# RUN Rscript --slave --no-save --no-restore-history /tmp/install.R

# Install extra python libs
COPY python3/py-requirements.txt /tmp/py-requirements.txt
RUN conda install --yes --file /tmp/py-requirements.txt


# Install Swift
USER root
#RUN mkdir -p /opt/swift && \
#    cd /opt/swift && \
#    apt update -y && \
#    apt install -y clang libcurl3 libicu-dev libpython-dev libncurses5-dev && \
#    wget https://storage.googleapis.com/swift-tensorflow/ubuntu16.04/swift-tensorflow-DEVELOPMENT-2019-01-04-a-ubuntu16.04.tar.gz && \
#    tar -vxzf swift-tensorflow-DEVELOPMENT-2019-01-04-a-ubuntu16.04.tar.gz && \
#    rm *.tar.gz
#ENV PATH /opt/swift/usr/bin:${PATH}

USER $NB_UID

# Extra Jupyter extensions

# Server proxy
RUN pip install jupyter-server-proxy jupyter-rsession-proxy && \
    jupyter labextension install jupyterlab-server-proxy

# Git support: https://github.com/jupyterlab/jupyterlab-git
RUN jupyter labextension install @jupyterlab/git && \
    pip install jupyterlab-git && \
    jupyter serverextension enable --py jupyterlab_git

# HTML support: https://github.com/mflevine/jupyterlab_html
RUN jupyter labextension install @mflevine/jupyterlab_html

# Latex support: https://github.com/jupyterlab/jupyterlab-latex
RUN pip install jupyterlab_latex && \
    jupyter labextension install @jupyterlab/latex

USER root

COPY hooks/start-notebook.d /usr/local/bin/start-notebook.d
COPY hooks/before-notebook.d /usr/local/bin/before-notebook.d

# Spark config
COPY spark/spark-defaults.conf /usr/local/spark/conf/spark-defaults.conf

USER $NB_UID
