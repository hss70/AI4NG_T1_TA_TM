# Use the official MATLAB Runtime base image
FROM mathworks/matlab-runtime:r2023b

# Install required utilities
RUN apt-get update && \
    apt-get install -y unzip awscli && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the compiled MATLAB executable and CTF file
COPY T1Trainer ./
COPY T1Trainer.ctf ./

# Copy the helper script
COPY download_and_run.sh ./
RUN chmod +x download_and_run.sh

# Set entrypoint
ENTRYPOINT ["./download_and_run.sh"]