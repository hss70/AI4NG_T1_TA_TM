#!/bin/bash

# Navigate to the MATLAB source directory
cd "../matlab" || { echo "Failed to change directory to ../matlab"; exit 1; }

# Compile the MATLAB code for the FBCSP training script
echo "Compiling MATLAB code..."

matlab -batch "compileMatlabCodeLinux"

echo "MATLAB compilation completed."