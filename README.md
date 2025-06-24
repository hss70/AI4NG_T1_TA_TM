### AI4NG T1_TA_TM training pipeline
## For use with the FBCSP classifier
This repository contains the infrastructure code for the AI4NG EEG Processing Pipeline, which automates the processing of EEG data files, tracks processing status, and provides a REST API for status checks. This readme just decribes the infra and lambda procedures. The containerisation is explained in scr/ContainerCode/README.md

flowchart TD
    A[User Uploads .zip] -->|S3 Event| B[S3EventProcessorLambda]
    B -->|Start Execution| C[Step Function]
    C --> D[Extract Session Info]
    D --> E[Record Start in DynamoDB]
    E --> F[Run ECS Task]
    F --> G{Success?}
    G -->|Yes| H[Wait for Manifest]
    G -->|No| I[Record Failure]
    H --> J[Process Manifest]
    J --> K{Processing Path}
    K -->|Classifier| L[Process Classifier]
    K -->|Metadata| M[Process Metadata]
    L --> N{Metadata?}
    N -->|Yes| M
    N -->|No| O[Record Success]
    M --> O
    I --> P[End]
    O --> P

## Key Components
# S3 Buckets

- Upload Bucket: Receives user-uploaded EEG data (.zip files)

- Results Bucket: Stores processed EEG results

# AWS Step Function

- Orchestrates the entire processing workflow

- Coordinates between ECS, Lambda, and DynamoDB

# AWS Lambda Functions

- S3 Event Processor: Triggers processing pipeline

- Manifest Processor: Processes manifest files

- Classifier Processor: Processes classifier data

- Metadata Processor: Processes metadata

- Status Check: Provides API for status queries

# Amazon ECS

Runs EEG classification tasks in Fargate containers

# DynamoDB Tables

- ProcessingStatusTable: Tracks session processing status

- EEGClassifierTable: Stores classifier parameters

## Prerequisites
Prerequisites
Before deployment, ensure you have:
1. AWS account with sufficient permissions

2. AWS CLI installed and configured

3. AWS SAM CLI installed and configured

4. Node.js 22.x+ for Lambda functions

5. Docker for building ECR image

6. GitHub repository secrets configured:

    - AWS_ACCESS_KEY_ID

    - AWS_SECRET_ACCESS_KEY


7. This is part of the AI4NG project. This pipeline is dependent on the following repos and the infra inside of them:
- https://github.com/hss70/AI4NG_VPC
- https://github.com/hss70/AI4NGUploadLambda
You can alternatively bring in the infra from these and deploy them together if you want

8. The following CloudFormation exports must exist:
    - EEGUploadBucketName
    - SharedApiId
    - NetworkStack-PrivateSG
    - NetworkStack-PrivateSubnetIds

## Deployment Instructions
Before deploying it is useful to validate the changes locally.
1. build the template
`sam build --template-file .\infra\trainingPipelineTemplate.yaml --region eu-west-2`
2. validate the template normally
`sam validate --template-file .\infra\trainingPipelineTemplate.yaml --region eu-west-2`
3. validate the template using --lint
`sam validate --template-file .\infra\trainingPipelineTemplate.yaml --region eu-west-2 --lint`
This catches most issues early on. I found that I had to run these commands on powershell in admin mode. 

# Deployment Workflows
1. Infrastructure Deployment Workflow
This workflow deploys the CloudFormation stack when changes are made to infrastructure files or Lambda code. Located at .github/workflows/deploy-infra.yml
2. Container Deployment Workflow
This workflow builds and pushes the classifier Docker container when changes are made to the container code. Located at .github/workflows/containerise-deploy.yml

# Manual Deployment (via GitHub Actions)
1. Navigate to your GitHub repository
2. Go to "Actions" tab
3. Run the "Deploy Infrastructure" workflow
4. After infrastructure deployment, run the "Build and Push Classifier Container" workflow

# Trigger-based Deployment
The workflows are automatically triggered when changes are pushed to relevant paths:

Infrastructure changes: infra/** or src/PostProcessingLambdas/**

Container changes: src/ContainerCode/**

## Lambda Function Details
# S3 Event Processor Lambda
Path: lambdas/s3EventProcessor/

Purpose: Triggers processing pipeline on .zip upload

Environment Variables:

STATE_MACHINE_ARN: ARN of processing state machine

# Manifest Processor Lambda
Path: lambdas/manifestProcessor/

Purpose: Processes manifest JSON files

Environment Variables:

STATUS_TABLE: ProcessingStatusTable name

# Classifier Processor Lambda
Path: lambdas/classifierProcessor/

Purpose: Processes classifier JSON files

Environment Variables:

CLASSIFIER_TABLE: EEGClassifierTable name

# Results Metadata Lambda
Path: lambdas/resultsMetadata/

Purpose: Processes metadata JSON files

Environment Variables:

STATUS_TABLE: ProcessingStatusTable name

Status Check Lambda
Path: lambdas/statusCheck/

Purpose: Provides API endpoint for status checks

Environment Variables:

STATUS_TABLE: ProcessingStatusTable name

## Testing the pipeline
1. Upload the test file
    - upload the test file via the NeuroPrecise app
    - alternitevly, add a zip directly to the bucket using the following structure:

    UPLOAD_BUCKET/uploads/user123/session456/test_data.zip. The upload bucket name will depend on your environment. I use
    `
        aws cloudformation describe-stack-events  --profile hardeepGmail --region eu-west-2
    `
    To find it.

2. Check Processing Status
# Get API endpoint from CloudFormation outputs
`
    ENDPOINT=$(aws cloudformation describe-stacks \
    --stack-name AI4NG-EEG-Pipeline \
    --query "Stacks[0].Outputs[?OutputKey=='StatusApiUrl'].OutputValue" \
    --output text)
`
# Call status API
`
    curl -H "Authorization: Bearer YOUR_TOKEN" $ENDPOINT/session456
`
3. Monitor Execution
- View Step Function executions in AWS Console
- Check CloudWatch Logs for each Lambda function
- Monitor ECS tasks in Fargate cluster

## Important Resources
After deployment, note these outputs:

- Status API URL: https://<api-id>.execute-api.<region>.amazonaws.com/dev/api/status/
- Results Bucket: ai4ng-eeg-results-<account-id>-<region>
- ECR Repository: <account-id>.dkr.ecr.<region>.amazonaws.com/eeg-classifier
- State Machine ARN: arn:aws:states:<region>:<account-id>:stateMachine:...

You can always find these on Github actions on the latest deployment. Or you can use the `aws cloudformation describe-stacks` to find them.


Cleanup
To delete all resources:

Empty S3 buckets:

bash
aws s3 rm s3://ai4ng-eeg-results-<account-id>-<region> --recursive
aws s3 rm s3://YOUR_UPLOAD_BUCKET/uploads --recursive
Delete ECR repository:

bash
aws ecr delete-repository --repository-name eeg-classifier --force
Delete CloudFormation stack:

bash
aws cloudformation delete-stack --stack-name AI4NG-EEG-Pipeline
## Troubleshooting
# Deployment failures:

- Check CloudFormation events for error details

- Verify all parameters are correctly specified

- Ensure ECR image exists before deployment

# Processing failures:

- Check Step Function execution history

- Review CloudWatch logs for Lambda functions

- Verify ECS task has necessary permissions

# API issues:

- Validate JWT token in API requests

- Check API Gateway logs for errors

- Verify DynamoDB table permissions

## Support
For assistance, contact the AI4NG team at hss70@bath.ac.uk