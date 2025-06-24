# Use the official MATLAB Runtime base image for R2024b
FROM containers.mathworks.com/matlab-runtime:r2024b
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
# Copy the compiled MATLAB executable and its runner script
COPY src/ContainerCode/ClassifierTraining/Code/output/FBCSP_Training ./FBCSP_Training
COPY src/ContainerCode/ClassifierTraining/Code/output/run_FBCSP_Training.sh ./run_FBCSP_Training.sh
RUN chmod +x FBCSP_Training run_FBCSP_Training.sh
# Copy the EEG channel locations file
COPY src/ContainerCode/ClassifierTraining/Code/Standard-10-20-Cap81.locs ./Standard-10-20-Cap81.locs
# Copy the main execution script
COPY src/ContainerCode/download_and_run.sh ./download_and_run.sh
RUN chmod +x download_and_run.sh
# Set the entrypoint to the main execution script
ENTRYPOINT ["./download_and_run.sh"]