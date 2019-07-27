ARG BASE_CONTAINER=kozai/runtime-base:latest
FROM $BASE_CONTAINER

COPY r35.yml /tmp/r35.yml
RUN conda env update -f /tmp/r35.yml
ENV PATH=/opt/conda/envs/r35/bin/:$PATH

# COPY R/install.R /tmp/install.R
# RUN Rscript --slave --no-save --no-restore-history /tmp/install.R
