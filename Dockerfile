# Use an available CUDA image with cuDNN 8 and Ubuntu 22.04
FROM nvidia/cuda:12.2.2-cudnn8-runtime-ubuntu22.04

# Install system dependencies including Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    wget \
    git \
    curl \
    unzip \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic links for python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Set working directory
WORKDIR /app

# Download the AFmassive run script
RUN wget -O /usr/local/bin/run_AFmassive.py https://raw.githubusercontent.com/GBLille/AFmassive/main/run_AFmassive.py \
    && chmod +x /usr/local/bin/run_AFmassive.py

# Download environment.yml to extract dependencies
RUN wget https://raw.githubusercontent.com/GBLille/AFmassive/main/environment.yml

# Install Python dependencies directly with pip (based on AFmassive requirements)
RUN pip3 install --no-cache-dir \
    numpy \
    scipy \
    pandas \
    matplotlib \
    seaborn \
    biopython \
    requests \
    absl-py \
    chex \
    dm-haiku \
    dm-tree \
    immutabledict \
    jax \
    ml-collections \
    tensorflow \
    alphafold-colabfold[alphafold] \
    && pip3 cache purge

# Create directory structure for alphafold
RUN mkdir -p /usr/local/lib/python3.10/dist-packages/alphafold/common/

# Download the stereo_chemical_props.txt file
RUN wget -O /usr/local/lib/python3.10/dist-packages/alphafold/common/stereo_chemical_props.txt \
    https://git.scicore.unibas.ch/schwede/openstructure/-/raw/7102c63615b64735c4941278d92b554ec94415f8/modules/mol/alg/src/stereo_chemical_props.txt

# Set environment variables
ENV PYTHONPATH=/usr/local/lib/python3.10/dist-packages:$PYTHONPATH
ENV PATH=/usr/local/bin:$PATH

# Set default command
CMD ["python3", "run_AFmassive.py", "--help"]