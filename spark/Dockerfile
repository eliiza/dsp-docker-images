FROM kozai/runtime-python37:latest
ARG TINI_VERSION="v0.18.0"

USER root

# Tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
RUN chmod +x /sbin/tini

RUN mkdir -p /usr/local/spark/work-dir && chmod g+w /usr/local/spark/work-dir
WORKDIR /usr/local/spark/work-dir

ENTRYPOINT [ "/usr/local/spark/kubernetes/dockerfiles/spark/entrypoint.sh" ]
