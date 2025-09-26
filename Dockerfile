FROM nvidia/cuda:12.2.2-runtime-ubuntu22.04

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget git bzip2 ca-certificates curl unzip build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# Install Miniconda (can be swapped with mambaforge for lighter base)
ENV CONDA_DIR=/opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p $CONDA_DIR \
    && rm /tmp/miniconda.sh \
    && $CONDA_DIR/bin/conda clean --all --yes \
    && rm -rf /opt/conda/pkgs/*

ENV PATH=$CONDA_DIR/bin:$PATH
WORKDIR /app

# Configure conda
RUN conda config --set channel_priority strict \
    && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main \
    && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Create AFmassive environment and clean in SAME layer
RUN wget -q https://raw.githubusercontent.com/GBLille/AFmassive/main/environment.yml -O environment.yml \
    && conda env create -f environment.yml \
    && conda clean --all --yes \
    && rm -rf /opt/conda/pkgs/* /root/.cache/* environment.yml

# Add AFmassive runner
RUN wget -q -O $CONDA_DIR/envs/AFmassive/bin/run_AFmassive.py \
    https://raw.githubusercontent.com/GBLille/AFmassive/main/run_AFmassive.py \
    && chmod +x $CONDA_DIR/envs/AFmassive/bin/run_AFmassive.py

# Add stereo_chemical_props.txt
RUN wget -q -O $CONDA_DIR/envs/AFmassive/lib/python3.10/site-packages/alphafold/common/stereo_chemical_props.txt \
    https://git.scicore.unibas.ch/schwede/openstructure/-/raw/7102c63615b64735c4941278d92b554ec94415f8/modules/mol/alg/src/stereo_chemical_props.txt

# Ensure AFmassive env is first in PATH
ENV PATH=$CONDA_DIR/envs/AFmassive/bin:$PATH