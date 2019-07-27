ARG BASE_CONTAINER=kozai/runtime-base:latest
FROM $BASE_CONTAINER

###
### Swift
###
USER root
ENV SWIFT_VERSION RELEASE-0.4
RUN mkdir -p /opt/swift && \
   cd /opt/swift && \
   apt update -y && \
   apt install -y clang libcurl3 libicu-dev libpython-dev libncurses5-dev libblocksruntime-dev && \
   wget https://storage.googleapis.com/swift-tensorflow-artifacts/releases/v0.4/rc4/swift-tensorflow-$SWIFT_VERSION-cuda9.2-cudnn7-ubuntu18.04.tar.gz && \
   tar -vxzf swift-tensorflow-$SWIFT_VERSION-cuda9.2-cudnn7-ubuntu18.04.tar.gz && \
   rm *.tar.gz

USER $NB_USER
