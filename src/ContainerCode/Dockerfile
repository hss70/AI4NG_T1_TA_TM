# Use the official MATLAB Runtime base image
FROM containers.mathworks.com/matlab-runtime:latest

# Install required utilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        unzip \
        jq \
        curl \
        python3-pip \
        libxext6 \
        libxt6 \
        libxmu6 \
        libgl1-mesa-glx \
        libglu1-mesa && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 install --no-cache-dir awscli

# Set the working directory
WORKDIR /app

# Copy the compiled MATLAB executables (both Windows and Linux versions)
COPY src/ContainerCode/ClassifierTraining/Code/output/FBCSP_Training ./

# Copy only the required EEG channel locations file
COPY src/ContainerCode/ClassifierTraining/Code/Standard-10-20-Cap81.locs ./

# Copy the helper script
COPY src/ContainerCode/download_and_run.sh ./
RUN chmod +x download_and_run.sh

# Set entrypoint
ENTRYPOINT ["./download_and_run.sh"]