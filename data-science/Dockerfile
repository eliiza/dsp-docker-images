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
COPY python3/conda-requirements.txt /tmp/python3/conda-requirements.txt

# Conda packages
RUN conda install --yes -c conda-forge -c defaults --file /tmp/python3/conda-requirements.txt && \
    conda clean -tipsy

# OpenAI GYM package
RUN git clone https://github.com/openai/gym.git && \
    cd gym && \
    pip install -e . && \
    cd .. && \
    rm -Rf gym

# PIP packages
COPY python3/pip-requirements.txt /tmp/python3/pip-requirements.txt
RUN pip install -r /tmp/python3/pip-requirements.txt

USER $NB_UID
