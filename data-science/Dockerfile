FROM eliiza/dsp-base:latest

###
### R
###

# R packages
COPY R/r-requirements.txt /tmp/r-requirements.txt
RUN conda install --yes -c r --file /tmp/r-requirements.txt && \
    conda clean -tipsy

# COPY R/install.R /tmp/install.R
# RUN Rscript --slave --no-save --no-restore-history /tmp/install.R

###
### PYTHON
###

# Install extra python libs
COPY python3/py-requirements.txt /tmp/py-requirements.txt

# Conda packages
RUN conda install --yes --file /tmp/py-requirements.txt && \
    conda clean -tipsy

# OpenAI GYM package
RUN git clone https://github.com/openai/gym.git && \
    cd gym && \
    pip install -e . && \
    cd .. && \
    rm -Rf gym

# PIP packages
RUN pip install fpdf \
    gym \
    dask-cuda \
    dask-cudf \
    dask-cuml \
    dask-kubernetes

USER $NB_UID
