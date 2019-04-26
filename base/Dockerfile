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
### Nvidia CUDA
###

### BASE INSTALL
RUN apt-get update && apt-get install -y --no-install-recommends gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl && \
    rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 10.0.130
ENV CUDA_PKG_VERSION 10-0=$CUDA_VERSION-1
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.0 brand=tesla,driver>=384,driver<385"
ENV NCCL_VERSION 2.4.2
ENV CUDNN_VERSION 7.4.2.24
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-cudart-$CUDA_PKG_VERSION \
        cuda-compat-10-0=410.48-1 \
        libcudnn7=$CUDNN_VERSION-1+cuda10.0 \
        cuda-libraries-$CUDA_PKG_VERSION \
        cuda-nvtx-$CUDA_PKG_VERSION \
        libnccl2=$NCCL_VERSION-1+cuda10.0 \
        cuda-command-line-tools-$CUDA_PKG_VERSION && \
    ln -s cuda-10.0 /usr/local/cuda && \
    apt-mark hold libnccl2 libcudnn7 && \
    rm -rf /var/lib/apt/lists/* && \
    ldconfig /usr/local/cuda/compat/

ENV PATH /usr/local/cuda/bin:${PATH}
ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs
ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:${LD_LIBRARY_PATH}

###
### END CUDA
###

###
### Swift
###
RUN mkdir -p /opt/swift && \
   cd /opt/swift && \
   apt update -y && \
   apt install -y clang libcurl3 libicu-dev libpython-dev libncurses5-dev libblocksruntime-dev && \
   wget https://storage.googleapis.com/s4tf-kokoro-artifact-testing/latest/swift-tensorflow-DEVELOPMENT-cuda10.0-cudnn7-ubuntu18.04.tar.gz && \
   tar -vxzf swift-tensorflow-DEVELOPMENT-cuda10.0-cudnn7-ubuntu18.04.tar.gz && \
   rm *.tar.gz
ENV PATH /opt/swift/usr/bin:${PATH}
###
### End Swift
###

RUN fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    fix-permissions $R_LIBS_USER && \
    fix-permissions /home/$NB_USER/.conda/

USER $NB_UID
