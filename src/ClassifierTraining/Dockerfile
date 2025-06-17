# Use the official MATLAB Runtime base image
FROM mathworks/matlab-runtime:r2023b

# Set the working directory
WORKDIR /app

# Copy the compiled MATLAB executable and CTF file
COPY T1Trainer ./
COPY T1Trainer.ctf ./

# Copy the helper script for data download and execution
COPY download_and_run.sh ./
RUN chmod +x download_and_run.sh

# Create output directory
RUN mkdir -p /app/results

# Environment variables (override at runtime if needed)
ENV OUTPUT_DIR=/app/results

# Set entrypoint to download data and run the MATLAB executable
ENTRYPOINT ["./download_and_run.sh"]
