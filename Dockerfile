 FROM dolfinx/dev-env

ARG DOLFINY_BUILD_TYPE=Release

ARG UFL_GIT_COMMIT=3cdfb8a
ARG BASIX_GIT_COMMIT=e7ff5c1
ARG FFCX_GIT_COMMIT=14f9a1d
ARG DOLFINX_GIT_COMMIT=f544b76

ENV PYTHONDONTWRITEBYTECODE=1

RUN git clone --branch main https://github.com/FEniCS/basix.git \
        && cd basix \
        && git checkout $BASIX_GIT_COMMIT \
        && cmake -G Ninja -DCMAKE_BUILD_TYPE=$DOLFINY_BUILD_TYPE -B build -S . \
        && cmake --build build \
        && cmake --install build \
        && python3 -m pip install ./python \
    && \
    pip3 install git+https://github.com/FEniCS/ufl.git@$UFL_GIT_COMMIT \
    && \
    pip3 install git+https://github.com/FEniCS/ffcx.git@$FFCX_GIT_COMMIT

RUN git clone --branch main https://github.com/FEniCS/dolfinx.git \
        && cd dolfinx \
        && git checkout $DOLFINX_GIT_COMMIT \
        && export PETSC_ARCH=linux-gnu-real-32 \
        && cmake -G Ninja -DCMAKE_BUILD_TYPE=$DOLFINY_BUILD_TYPE -B build -S ./cpp/ \
        && cmake --build build \
        && cmake --install build \
        && python3 -m pip install ./python


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

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
WORKDIR ${HOME}
USER root
COPY . ${HOME}
RUN pip3 install -r requirements.txt
RUN chown -R ${NB_USER} ${HOME}
USER ${USER}
# ENTRYPOINT ["jupyter", "notebook", "--ip", "0.0.0.0", "--no-browser", "--allow-root"]
