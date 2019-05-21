FROM eliiza/dsp-data-science:latest

LABEL maintainer="Ray Hilton <ray.hilton@eliiza.com.au>"

USER root

### rstudio
# You can use rsession from rstudio's desktop package as well.
ARG RSTUDIO_PKG=rstudio-server-1.1.463-amd64.deb
RUN wget -q http://download2.rstudio.org/${RSTUDIO_PKG} && \
    dpkg -i ${RSTUDIO_PKG} && \
    rm ${RSTUDIO_PKG}

### Install Swift
USER root
#RUN mkdir -p /opt/swift && \
#    cd /opt/swift && \
#    apt update -y && \
#    apt install -y clang libcurl3 libicu-dev libpython-dev libncurses5-dev && \
#    wget https://storage.googleapis.com/swift-tensorflow/ubuntu16.04/swift-tensorflow-DEVELOPMENT-2019-01-04-a-ubuntu16.04.tar.gz && \
#    tar -vxzf swift-tensorflow-DEVELOPMENT-2019-01-04-a-ubuntu16.04.tar.gz && \
#    rm *.tar.gz
#ENV PATH /opt/swift/usr/bin:${PATH}

### DASK
COPY config/dask-config.yaml /etc/dask/config.yaml

USER $NB_UID

# Apache Toree kernel
#RUN pip install --no-cache-dir \
#    https://dist.apache.org/repos/dist/release/incubator/toree/0.3.0-incubating/toree-pip/toree-0.3.0.tar.gz && \
#    jupyter toree install --sys-prefix && \
#    rm -rf /home/$NB_USER/.local

# Spylon-kernel
#RUN conda install --quiet --yes 'spylon-kernel=0.4*' && \
#    conda clean -tipsy && \
#    python -m spylon_kernel install --sys-prefix && \
#    rm -rf /home/$NB_USER/.local

# Extra Jupyter extensions
RUN pip install jupyterhub==0.9.6

# Quick Open
# https://github.com/parente/jupyterlab-quickopen
RUN pip install jupyterlab-quickopen && \
    jupyter labextension install @parente/jupyterlab-quickopen

# DrawIO
RUN jupyter labextension install jupyterlab-drawio

# Dask UI
RUN pip install dask_labextension && \
    jupyter labextension install dask-labextension

# Server proxy
RUN pip install jupyter-server-proxy jupyter-rsession-proxy && \
    jupyter labextension install jupyterlab-server-proxy

# Git support: https://github.com/jupyterlab/jupyterlab-git
RUN jupyter labextension install @jupyterlab/git && \
    pip install jupyterlab-git && \
    jupyter serverextension enable --py jupyterlab_git

# TOC
RUN jupyter labextension install @jupyterlab/toc

# HTML support: https://github.com/mflevine/jupyterlab_html
# RUN jupyter labextension install @mflevine/jupyterlab_html

# Latex support: https://github.com/jupyterlab/jupyterlab-latex
RUN pip install jupyterlab_latex && \
   jupyter labextension install @jupyterlab/latex

# Install beakerx
# RUN conda install -c conda-forge ipywidgets beakerx

# Swift kernel
RUN cd /opt/ && \
    git clone https://github.com/google/swift-jupyter.git && \
    cd swift-jupyter/ && \
    python3 register.py --sys-prefix --swift-toolchain /opt/swift/ --swift-python-library /usr/lib/x86_64-linux-gnu/libpython3.6m.so --kernel-name "Swift" && \
    ls -la /opt/conda/share/jupyter/kernels/

# NBEXTENSIONS
RUN pip install jupyter_contrib_nbextensions && \
   jupyter contrib nbextension install --sys-prefix && \
   pip install jupyter_nbextensions_configurator && \
   jupyter nbextensions_configurator enable --sys-prefix

USER root

# Enable Extension manager
COPY config/plugin.jupyterlab-settings.json ~/.jupyter/lab/user-settings/@jupyterlab/extensionmanager-extension/plugin.jupyterlab-settings

# Make sure CUDA is available
RUN ldconfig /usr/local/cuda/compat/

COPY config/jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py
COPY hooks/start-notebook.d /usr/local/bin/start-notebook.d
# COPY hooks/before-notebook.d /usr/local/bin/before-notebook.d

USER $NB_UID


### Theia
RUN pip install python-language-server[all] pyls-mypy pyls-isort pyls-black
USER root
COPY theia /opt/theia
RUN chown -R root /opt/theia && \
    cd /opt/theia && \
    npm install -g yarn && \
    yarn && \
    yarn theia build && \
    rm -rf /opt/theia/node_modules/electron && \
    yarn cache clean
ENV PATH=/opt/theia/node_modules/.bin:$PATH

RUN cd /opt/theia/proxy && \
    python setup.py build && \
    python setup.py install

RUN chown -R $NB_UID /opt/theia

USER $NB_UID
