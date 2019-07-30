ARG BASE_CONTAINER=kozai/runtime-python37:latest
FROM $BASE_CONTAINER

USER root

# Dumb init
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

COPY prepare.sh /usr/bin/prepare.sh
RUN chmod +x /usr/bin/prepare.sh

USER $NB_USER

ENTRYPOINT ["/usr/local/bin/dumb-init", "/usr/bin/prepare.sh"]
