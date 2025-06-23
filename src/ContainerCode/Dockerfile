# Use the official MATLAB Runtime base image for R2024b
FROM containers.mathworks.com/matlab-runtime:R2024b

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

# Copy the compiled MATLAB executable and its runner script
COPY src/ContainerCode/ClassifierTraining/Code/output/FBCSP_Training ./
COPY src/ContainerCode/ClassifierTraining/Code/output/run_FBCSP_Training.sh ./
RUN chmod +x FBCSP_Training run_FBCSP_Training.sh

# Copy the EEG channel locations file
COPY src/ContainerCode/ClassifierTraining/Code/Standard-10-20-Cap81.locs ./

# Copy the main execution script
COPY src/ContainerCode/download_and_run.sh ./
RUN chmod +x download_and_run.sh

# Set entrypoint
ENTRYPOINT ["./download_and_run.sh"]