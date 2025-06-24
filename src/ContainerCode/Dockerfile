# Use the official MATLAB Runtime base image for R2024b
FROM containers.mathworks.com/matlab-runtime:r2024b
LABEL maintainer="hss70@bath.ac.uk"
LABEL description="Container for running FBCSP MATLAB classification training."

# Install required utilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        jq \
        libgl1-mesa-glx \
        libglu1-mesa \
        libxext6 \
        libxmu6 \
        libxt6 \
        python3-pip \
        unzip && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 install --no-cache-dir awscli
# Set the working directory
WORKDIR /app

# --- Application and Dependencies ---
# The paths below are relative to the 'src/ContainerCode' build context.

# CRITICAL: Your MATLAB application must be compiled on a Linux system
# to work in this container. Copy the artifacts from your LINUX build.
COPY ClassifierTraining/Code/output/FBCSP_Training ./FBCSP_Training
COPY ClassifierTraining/Code/output/run_FBCSP_Training.sh ./run_FBCSP_Training.sh

# Copy required data files. Ensure your MATLAB code knows to look for this in the current directory (/app).
COPY ClassifierTraining/Code/Standard-10-20-Cap81.locs ./Standard-10-20-Cap81.locs

# Copy the main execution script that orchestrates the download and run process.
COPY download_and_run.sh ./download_and_run.sh

# Make all scripts and the application executable.
RUN chmod +x ./FBCSP_Training ./run_FBCSP_Training.sh ./download_and_run.sh

# Set the entrypoint to the main execution script.
ENTRYPOINT ["./download_and_run.sh"]