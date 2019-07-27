ARG BASE_CONTAINER=kozai/runtime-base:latest
FROM $BASE_CONTAINER

COPY python37.yml /tmp/python37.yml
RUN conda env update -f /tmp/python37.yml
ENV PATH=/opt/conda/envs/python37/bin/:$PATH
