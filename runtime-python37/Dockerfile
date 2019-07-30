ARG BASE_CONTAINER=kozai/runtime-base:latest
FROM $BASE_CONTAINER

ARG environment_file="python37"
COPY ${environment_file}.yml /tmp/env.yml
RUN conda env update -f /tmp/env.yml
ENV PATH=/opt/conda/envs/${environment_file}/bin/:$PATH
