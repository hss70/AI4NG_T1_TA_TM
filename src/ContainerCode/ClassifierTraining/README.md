
# EEG Classifier Container

This folder contains the **MATLAB-based classifier pipeline** and the **Dockerfile** to run it in a containerized environment (like ECS Fargate).

---

## 🟩 Prerequisites

✅ **MATLAB & MATLAB Compiler**  
- You need MATLAB and the MATLAB Compiler (`mcc`) to compile your `T1_TA_TM.m` script into a standalone executable.

✅ **Docker**  
- Install Docker Desktop or Docker Engine on your local machine.

✅ **AWS CLI**  
- Install and configure with your AWS credentials (`aws configure`).

✅ **AWS S3 bucket** for storing raw EEG data and results.

---

## 🟩 MATLAB Compilation (if script changes)

If you **change** the MATLAB source code (`T1_TA_TM.m` or helpers), you need to **recompile**:

1️⃣ Open MATLAB and navigate to this folder:

```matlab
cd('src/classifier/')
```

2️⃣ Compile using `mcc`:

```matlab
mcc -m T1_TA_TM.m -o T1Trainer
```

This will generate:
- `T1Trainer` (executable)
- `T1Trainer.ctf` (MATLAB runtime data)

✅ **Commit these new files** to the repo (`T1Trainer`, `T1Trainer.ctf`).

---

## 🟩 How to Build the Docker Image

1️⃣ Build the Docker image:

```bash
docker build -t eeg-classifier:latest .
```

This uses:
- `Dockerfile` for MATLAB Runtime base image
- `download_and_run.sh` script for S3 download & execution

---

## 🟩 How to Run the Container Locally

```bash
docker run --rm   -e AWS_ACCESS_KEY_ID=xxx   -e AWS_SECRET_ACCESS_KEY=xxx   -e AWS_DEFAULT_REGION=eu-west-2   eeg-classifier:latest
```

This will:
1️⃣ Download EEG CSV data from your S3 bucket  
2️⃣ Run the compiled MATLAB classifier script  
3️⃣ Save results to `/app/results` inside the container

---

## 🟩 How to Access Output Data

✅ To **copy output data** to your local machine:

```bash
docker cp <container_id>:/app/results ./results
```

✅ Or to **upload directly to S3** (replace with your bucket name):

```bash
aws s3 cp ./results s3://my-results-bucket/ --recursive
```

---

## 🟩 ECS / Fargate Integration

In production, this container image will be **deployed to ECS Fargate** as part of your **Step Functions pipeline**.  
- IAM roles will handle S3 permissions.  
- No need to pass AWS keys at runtime.

---

## 🟩 Notes & Maintenance

✅ If you **change any MATLAB code**, always:  
1️⃣ Recompile (`mcc -m T1_TA_TM.m -o T1Trainer`)  
2️⃣ Rebuild the Docker image (`docker build ...`)  
3️⃣ Push to your ECR repository (`docker push ...`)  

✅ This ensures your pipeline always uses the **latest MATLAB logic**.

---

## 🟩 Contact

Questions? Issues?  
Ping me (or the team) and we’ll troubleshoot together!
uni email: hss70@bath.ac.uk
personal email: hardeep95@live.co.uk
