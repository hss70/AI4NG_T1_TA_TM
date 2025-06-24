# EEG Classifier Container

This folder contains the **MATLAB-based classifier pipeline** and the **Dockerfile** to run it in a containerized environment (AWS Fargate). 

---

## 🟩 Prerequisites

### 🐧 Linux MATLAB Environment (Essential for Compilation)
- **You MUST compile the MATLAB code on a Linux system** to ensure compatibility with the Docker container
- Options:
  1. **MATLAB Online**: Use MATLAB Online (requires license)
  2. **Linux VM**: Create an Ubuntu VM (recommended)
  3. **Docker**: Use MATLAB's Docker image (advanced)
- MATLAB Compiler Runtime (MCR) will be installed automatically in the Docker image

### 📦 Required Software
| Software | Purpose | Installation |
|----------|---------|--------------|
| **MATLAB R2023b+** | Code compilation | [Linux Download](https://www.mathworks.com/support/install/matlab.html) |
| **Docker** | Containerization | `sudo apt install docker.io` |
| **AWS CLI** | AWS interaction | `curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && sudo ./aws/install` |

---

## 🟩 MATLAB Compilation (Linux Required)

### ⚠️ Critical: Must be done on Linux
```bash
# 1. Navigate to MATLAB source directory
cd src/classifier/

# 2. Launch MATLAB (GUI or command line)
matlab

## In Matlab
# 3. Add required dependencies to path
addpath(genpath('helper_functions'));

# 4. Compile main executable
mcc -m FBCSP_Training.m \
    -a ./Standard-10-20-Cap81.locs \
    -a ./feature_extraction \
    -a ./preprocessing \
    -d ./output \
    -v

🔄 Expected Output in output/ directory:
FBCSP_Training        # Compiled binary
FBCSP_Training.ctf    # Component Technology File
run_FBCSP_Training.sh # Bootstrap script

✅ Verify Linux Compatibility:
file output/FBCSP_Training
# Should show: ELF 64-bit LSB executable, x86-64