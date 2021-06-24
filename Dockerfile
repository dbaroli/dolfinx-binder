FROM dolfinx/lab

ENV HDF5_MPI="ON" \
    CC=mpicc \
    HDF5_DIR="/usr/lib/x86_64-linux-gnu/hdf5/mpich/"

# Install meshio
RUN pip3 install --no-cache-dir --no-binary=h5py h5py meshio


# Dependencies for pyvista and related packages
RUN wget -qO - https://deb.nodesource.com/setup_16.x | bash && \
    apt-get -qq update && \
    apt-get install -y libgl1-mesa-dev xvfb nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Pyvista ITKWidgets dependencies
RUN pip3 install --no-cache-dir --upgrade setuptools itkwidgets ipywidgets matplotlib pyvista ipyvtklink seaborn pandas
RUN jupyter labextension install jupyter-matplotlib jupyterlab-datawidgets itkwidgets




# Install progress-bar
RUN pip3 install tqdm pygments --upgrade
RUN pip3 install --no-cache --upgrade pip && \
    pip3 install --no-cache jupyterlab && \
    pip3 install --no-cache pyvista && \
    pip3 install --no-cache pyvirtualdisplay

# create user with a home directory
ARG NB_USER
ARG NB_UID
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}
ENV PYVISTA_OFF_SCREEN true
ENV PYVISTA_USE_PANEL true
ENV PYVISTA_PLOT_THEME document
# This is needed for Panel - use with cuation!
ENV PYVISTA_AUTO_CLOSE false
RUN pip3 install -r requirements.txt
RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
WORKDIR ${HOME}
USER root
COPY . ${HOME}

RUN chown -R ${NB_USER} ${HOME}
USER ${USER}
# ENTRYPOINT ["jupyter", "notebook", "--ip", "0.0.0.0", "--no-browser", "--allow-root"]
