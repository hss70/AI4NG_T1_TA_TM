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
| **MATLAB R2024b+** | Code compilation | [Linux Download](https://www.mathworks.com/support/install/matlab.html) |
| **Docker** | Containerization | `sudo apt install docker.io` |
| **AWS CLI** | AWS interaction | `curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && sudo ./aws/install` |

---

## 🟩 MATLAB Compilation (Linux Required)

### ⚠️ Critical: Must be done on Linux

**Option 1: Use the provided script (Recommended)**
```bash
# Navigate to ContainerCode directory
cd src/ContainerCode

# Run the compilation script
./compile_matlab.sh
```

**Option 2: Manual compilation**
```bash
# 1. Navigate to MATLAB source directory
cd src/matlab

# 2. Launch MATLAB (GUI or command line)
matlab
```

**In MATLAB:**
```matlab
% 3. Run the compilation script
compileMatlabCodeLinux
```

**Expected Output in `output/` directory:**
- `FBCSP_Training` - Compiled binary
- `FBCSP_Training.ctf` - Component Technology File  
- `run_FBCSP_Training.sh` - Bootstrap script

**Verify Linux Compatibility:**
```bash
file ClassifierTraining/Code/output/FBCSP_Training
# Should show: ELF 64-bit LSB executable, x86-64
```

---

## 🟩 Docker Build & Deployment

### Local Docker Build
```bash
# Navigate to ContainerCode directory
cd src/ContainerCode

# Build the Docker image
docker build -t eeg-classifier:latest .
```

### Test Locally (Optional)
```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID=your_key \
  -e AWS_SECRET_ACCESS_KEY=your_secret \
  -e AWS_DEFAULT_REGION=eu-west-2 \
  -e USER_ID=test_user \
  -e SESSION_ID=test_session \
  -e INPUT_FILE=test_data.zip \
  -e UPLOAD_BUCKET=your-upload-bucket \
  -e RESULTS_BUCKET=your-results-bucket \
  eeg-classifier:latest
```

### Deploy to AWS ECR
```bash
# Get ECR login token
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.eu-west-2.amazonaws.com

# Tag for ECR
docker tag eeg-classifier:latest <account-id>.dkr.ecr.eu-west-2.amazonaws.com/eeg-classifier:latest

# Push to ECR
docker push <account-id>.dkr.ecr.eu-west-2.amazonaws.com/eeg-classifier:latest
```

**Note:** The GitHub Actions workflow will automatically handle ECR deployment when you push changes to the `src/ContainerCode/` directory.

---

## 🟩 Complete Workflow

1. **Make MATLAB changes** in `ClassifierTraining/Code/`
2. **Compile on Linux** using `./compile_matlab.sh`
3. **Test Docker build** locally
4. **Commit and push** - GitHub Actions will deploy automatically

---

## 🟩 Troubleshooting

**MATLAB Compilation Issues:**
- Ensure you're on a Linux system
- Check MATLAB Compiler license
- Verify all dependencies are in the path

**Docker Build Issues:**
- Ensure compiled binaries exist in `ClassifierTraining/Code/output/`
- Check that binaries are Linux-compatible (ELF format)

**Runtime Issues:**
- Check environment variables are set correctly
- Verify S3 bucket permissions
- Check CloudWatch logs for detailed error messages