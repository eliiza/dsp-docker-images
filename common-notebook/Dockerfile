# FROM eliiza/dsp-base:cuda9.2
ARG BASE_CONTAINER=eliiza/dsp-base:cuda9.2
ARG RSTUDIO_PKG=rstudio-server-1.1.463-amd64.deb
ARG include_capabilities=""
FROM $BASE_CONTAINER
SHELL ["/bin/bash", "-c"]

LABEL maintainer="Ray Hilton <ray.hilton@eliiza.com.au>"

USER root

### rstudio
# You can use rsession from rstudio's desktop package as well.
RUN [[ $include_capabilities == *"rstudio"* ]] && \
    wget -q http://download2.rstudio.org/${RSTUDIO_PKG} && \
    dpkg -i ${RSTUDIO_PKG} && \
    rm ${RSTUDIO_PKG} || true

# Swift kernel
RUN [[ $include_capabilities == *"swift"* ]] && \
    cd /opt/ && \
    git clone https://github.com/google/swift-jupyter.git && \
    chown -R $NB_USER swift-jupyter || true

##
## JUPYTER
##

EXPOSE 8888
WORKDIR $HOME

# Configure container startup
ENTRYPOINT ["tini", "--"]
CMD ["start-notebook.sh"]

# Add local files as late as possible to avoid cache busting
COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/
COPY config/jupyter_notebook_config.py /etc/jupyter/
RUN fix-permissions /etc/jupyter/

# Enable Extension manager
COPY config/plugin.jupyterlab-settings.json ~/.jupyter/lab/user-settings/@jupyterlab/extensionmanager-extension/plugin.jupyterlab-settings

# Make sure CUDA is available
RUN ldconfig /usr/local/cuda/compat/

COPY hooks/start-notebook.d /usr/local/bin/start-notebook.d
# COPY hooks/before-notebook.d /usr/local/bin/before-notebook.d

USER $NB_USER

# SWift 
RUN [[ $include_capabilities == *"swift"* ]] && \
    cd /opt/swift-jupyter/ && \
    python3 register.py --sys-prefix --swift-toolchain /opt/swift/ --swift-python-library /usr/lib/x86_64-linux-gnu/libpython3.6m.so --kernel-name "Swift" && \
    ls -la /opt/conda/share/jupyter/kernels/ || true

# Install Jupyter Notebook and Hub
RUN conda install --quiet --yes \
    'notebook=5.7.8' \
    'jupyterhub=1.0.0' \
    'jupyterlab=1.0.1' && \
    conda clean --all -f -y && \
    npm cache clean --force && \
    jupyter notebook --generate-config && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

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

# NBEXTENSIONS
RUN pip install jupyter_contrib_nbextensions && \
   jupyter contrib nbextension install --sys-prefix && \
   pip install jupyter_nbextensions_configurator && \
   jupyter nbextensions_configurator enable --sys-prefix

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
