# Use an available CUDA image with cuDNN 8 and Ubuntu 22.04
FROM nvidia/cuda:12.2.2-cudnn8-runtime-ubuntu22.04

# Install needed system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget git bzip2 ca-certificates \
    curl unzip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
ENV CONDA_DIR=/opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p $CONDA_DIR \
    && rm /tmp/miniconda.sh \
    && $CONDA_DIR/bin/conda clean --all --yes

ENV PATH=$CONDA_DIR/bin:$PATH

# Set working directory
WORKDIR /app

# Accept conda Terms of Service
RUN conda config --set channel_priority strict \
    && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main \
    && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Download and create AFmassive environment following official documentation
RUN wget https://raw.githubusercontent.com/GBLille/AFmassive/main/environment.yml \
    && conda env create -f environment.yml \
    && conda clean --all --yes

# Download the run_AFmassive.py script to the conda environment bin directory
RUN wget -O $CONDA_DIR/envs/AFmassive/bin/run_AFmassive.py https://raw.githubusercontent.com/GBLille/AFmassive/main/run_AFmassive.py \
    && chmod +x $CONDA_DIR/envs/AFmassive/bin/run_AFmassive.py

# Download the stereo_chemical_props.txt file
RUN wget -O $CONDA_DIR/envs/AFmassive/lib/python3.10/site-packages/alphafold/common/stereo_chemical_props.txt \
    https://git.scicore.unibas.ch/schwede/openstructure/-/raw/7102c63615b64735c4941278d92b554ec94415f8/modules/mol/alg/src/stereo_chemical_props.txt

# Install cuda-nvcc if needed (uncomment if required by your infrastructure)
# RUN conda install -n AFmassive cuda-nvcc -c conda-forge -y

# Set environment variables for easier access
ENV PATH=$CONDA_DIR/envs/AFmassive/bin:$PATH

# Set default command to show help or run AFmassive
#CMD ["conda", "run", "--no-capture-output", "-n", "AFmassive", "python", "run_AFmassive.py", "--help"]