# FROM eliiza/dsp-base:cuda9.2
ARG BASE_CONTAINER=eliiza/dsp-base:cuda9.2
ARG include_capabilities=""
FROM $BASE_CONTAINER
SHELL ["/bin/bash", "-c"]

LABEL maintainer="Ray Hilton <ray.hilton@eliiza.com.au>"

USER root

### rstudio
# You can use rsession from rstudio's desktop package as well.
ENV RSTUDIO_PKG=rstudio-server-1.1.463-amd64.deb
RUN if [ -x "$(command -v R)" ]; then \
      wget -q http://download2.rstudio.org/$RSTUDIO_PKG && \
      dpkg -i ${RSTUDIO_PKG} && \
      rm ${RSTUDIO_PKG}; \
    fi

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
# Make sure CUDA is available
RUN ldconfig /usr/local/cuda/compat/

COPY hooks/start-notebook.d /usr/local/bin/start-notebook.d
# COPY hooks/before-notebook.d /usr/local/bin/before-notebook.d

USER $NB_USER

# Install Jupyter Notebook and Hub
RUN conda install --quiet --yes \
    'notebook=6.0.0' \
    'jupyterhub=1.0.0' \
    'jupyterlab=1.0.4' \
    dask_labextension \
    jupyter-server-proxy \
    jupyter_contrib_nbextensions \
    jupyter_nbextensions_configurator && \
    conda clean --all -f -y && \
    npm cache clean --force && \
    jupyter notebook --generate-config && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Enable Extension manager
COPY config/jupyter_notebook_config.py /etc/jupyter/
RUN fix-permissions /etc/jupyter/
COPY config/plugin.jupyterlab-settings.json ~/.jupyter/lab/user-settings/@jupyterlab/extensionmanager-extension/plugin.jupyterlab-settings

# SWift
RUN if [ -x "$(command -v swift)" ]; then \
      cd /opt/ && \
      git clone https://github.com/google/swift-jupyter.git && \
      cd swift-jupyter && \
      python3 register.py --sys-prefix --swift-toolchain /opt/swift/ --swift-python-library /usr/lib/x86_64-linux-gnu/libpython3.6m.so --kernel-name "Swift" && \
      ls -la /opt/conda/share/jupyter/kernels/; \
    fi

RUN pip install jupyterlab-quickopen
RUN jupyter labextension install @parente/jupyterlab-quickopen
RUN jupyter labextension install jupyterlab-drawio
RUN jupyter labextension install dask-labextension
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager
RUN jupyter labextension install @jupyterlab/hub-extension
# RUN jupyter labextension install jupyterlab_toastify jupyterlab_conda
RUN cd /tmp/ && \
    git clone --depth 1 https://github.com/jupyterhub/jupyter-server-proxy && \
    cd jupyter-server-proxy/jupyterlab-server-proxy && \
    npm install && npm run build && jupyter labextension link . && \
    npm run build && jupyter lab build 
RUN jupyter labextension install @jupyterlab/toc
RUN jupyter contrib nbextension install --sys-prefix
RUN jupyter nbextensions_configurator enable --sys-prefix

# RUN if [ -x "$(command -v python3.6)" ] || [ -x "$(command -v python3.7)" ]; then \
#       pip install jupyterlab_latex && \
#       jupyter labextension install @jupyterlab/latex && \
#       jupyter labextension install @jupyterlab/git && \
#       jupyter serverextension enable --py jupyterlab_git; \
#     fi

### Theia
USER root
COPY theia /opt/theia
RUN pip install python-language-server[all] pyls-mypy pyls-isort pyls-black && \
    chown -R root /opt/theia && \
    cd /opt/theia && \
    npm install -g yarn && \
    yarn && \
    yarn theia build && \
    rm -rf /opt/theia/node_modules/electron && \
    yarn cache clean && \
    cd /opt/theia/proxy && \
    python setup.py build && \
    python setup.py install || true
ENV PATH=/opt/theia/node_modules/.bin:$PATH
RUN chown -R $NB_UID /opt/theia
USER $NB_UID
