# AI4NG T1_TA_TM Training Pipeline
## For use with the FBCSP classifier
This repository contains the infrastructure code for the AI4NG EEG Processing Pipeline, which automates the processing of EEG data files, tracks processing status, and provides a REST API for status checks.

## Architecture Overview
The pipeline processes EEG .zip files uploaded to S3, runs classification in ECS containers, and stores results. It includes manifest-driven processing, T1 results extraction, and comprehensive status tracking.

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

### S3 Buckets
- **Upload Bucket** (`ai4ngstore-dev`): Receives user-uploaded EEG data (.zip files)
- **Results Bucket** (`ai4ng-eeg-results-*`): Stores processed EEG results, manifests, and classifier outputs

### AWS Step Function (`ProcessingStateMachine`)
Orchestrates the entire processing workflow:
1. **ExtractSessionInfo**: Parses upload path to extract userId, sessionName, and sessionId
2. **RecordProcessingStart**: Updates DynamoDB with PROCESSING status
3. **CheckSkipECS**: Optional bypass for ECS processing (for testing)
4. **LaunchECSTask**: Runs EEG classification in Fargate container
5. **WaitForManifest**: Polls for manifest.json file creation
6. **CheckManifestExists**: Verifies manifest file is available
7. **ProcessManifest**: Extracts processing results and file metadata
8. **CheckClassifierExists**: Verifies classifier JSON file exists
9. **CheckT1ResultsExists**: Verifies T1 results JSON file exists
10. **ProcessClassifier**: Extracts classifier parameters and T1 DA metrics
11. **CheckForMetadata**: Determines if additional metadata processing needed
12. **ProcessMetadata**: Handles optional metadata files
13. **RecordSuccess/RecordFailure**: Updates final processing status

### AWS Lambda Functions

#### S3EventProcessorLambda
- **Purpose**: Entry point triggered by S3 upload events
- **Trigger**: EventBridge rule on .zip file uploads
- **Actions**: 
  - Generates sessionId from userId+sessionName
  - Records upload in ProcessingStatusTableV2
  - Starts Step Function execution
- **Environment**: `STATE_MACHINE_ARN`, `STATUS_TABLE`

#### ManifestProcessorLambda
- **Purpose**: Processes manifest.json files created by ECS container
- **Trigger**: Step Function invocation
- **Actions**:
  - Parses manifest for processing results
  - Updates processing status and duration
  - Stores file metadata in FBCSPSessionFiles table
  - Sends SNS notifications
- **Environment**: `STATUS_TABLE`, `FILES_TABLE`, `SNS_TOPIC_ARN`

#### ClassifierProcessorLambda
- **Purpose**: Extracts FBCSP classifier parameters and T1 DA metrics
- **Trigger**: Step Function invocation
- **Actions**:
  - Processes classifier JSON files
  - Extracts EEG, CSP, CF, and MI parameters
  - Fetches T1 results for DA.smooth.taskPeakDA_mean/std
  - Stores in FBCSPClassifierParameters table
- **Environment**: `CLASSIFIER_TABLE`

#### ResultsMetadataLambda
- **Purpose**: Processes optional metadata JSON files
- **Trigger**: Step Function invocation (conditional)
- **Actions**: Updates processing status with metadata information
- **Environment**: `STATUS_TABLE`

#### GetStatusLambda
- **Purpose**: Provides REST API for processing status queries
- **Trigger**: API Gateway routes
- **Endpoints**:
  - `GET /api/status/{sessionId}` - Get specific session status
  - `GET /api/status` - Get all sessions (with optional status filter)
- **Features**: Includes ECS logs for failed/processing sessions
- **Environment**: `STATUS_TABLE`

#### AdminRetriggerLambda
- **Purpose**: Admin tool to reprocess all uploaded files
- **Trigger**: Manual console invocation only
- **Actions**:
  - Scans ProcessingStatusTableV2 for all sessions with uploadPath
  - Restarts Step Function for each session
  - Supports skipECS flag for testing
- **Environment**: `STATUS_TABLE`, `STATE_MACHINE_ARN`

### Amazon ECS
- **Cluster**: `EEG-Classifier-Cluster` (Fargate)
- **Task Definition**: `EEGClassifierTask`
- **Container**: `eeg-classifier` (1024 CPU, 4096 MB memory)
- **Purpose**: Runs MATLAB-based EEG classification algorithms
- **Outputs**: Creates manifest.json, classifier files, and T1 results

### DynamoDB Tables

#### ProcessingStatusTableV2 (`EEGProcessingStatusV2`)
- **Primary Key**: `sessionId` (Number)
- **Purpose**: Tracks processing status for each session
- **Fields**: sessionName, userId, status, startTime, endTime, uploadPath, processingDuration, resultsPath, exitCode, error
- **Indexes**: SessionNameIndex (sessionName)

#### EEGClassifierTable (`FBCSPClassifierParameters`)
- **Primary Key**: `classifierId` (Number)
- **Purpose**: Stores extracted classifier parameters and T1 DA metrics
- **Fields**: sessionId, userId, sessionName, timestamp, fileName, s3Key, peakAccuracy, errorMargin, eeg, csp, cf, mi parameters
- **Indexes**: UserIdTimestampIndex, SessionIdTimestampIndex

#### FBCSPSessionFilesTable (`FBCSPSessionFiles`)
- **Primary Key**: `sessionName` (HASH), `filePath` (RANGE)
- **Purpose**: Tracks all files created during processing
- **Fields**: sessionId, userId, createdAt, extension, fileName
- **Indexes**: SessionIdIndex, UserIdCreatedAtIndex, SessionIdExtensionIndex, SessionIdFileNameIndex

### Monitoring & Notifications
- **SNS Topic**: `EEGProcessingNotifications` - Email alerts for processing completion
- **CloudWatch Dashboard**: Real-time metrics for Step Functions, ECS, and Lambda performance
- **CloudWatch Alarms**: Alerts for Step Function failures, ECS task failures, and Lambda errors

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

### Deployment Workflows
1. Infrastructure Deployment Workflow
This workflow deploys the CloudFormation stack when changes are made to infrastructure files or Lambda code. Located at .github/workflows/deploy-infra.yml
2. Container Deployment Workflow
This workflow builds and pushes the classifier Docker container when changes are made to the container code. Located at .github/workflows/containerise-deploy.yml

### Manual Deployment (via GitHub Actions)
1. Navigate to your GitHub repository
2. Go to "Actions" tab
3. Run the "Deploy Infrastructure" workflow
4. After infrastructure deployment, run the "Build and Push Classifier Container" workflow

### Trigger-based Deployment
The workflows are automatically triggered when changes are pushed to relevant paths:

Infrastructure changes: infra/** or src/PostProcessingLambdas/**

Container changes: src/ContainerCode/**

## Lambda Function Details
### S3 Event Processor Lambda
Path: lambdas/s3EventProcessor/

Purpose: Triggers processing pipeline on .zip upload

Environment Variables:

STATE_MACHINE_ARN: ARN of processing state machine

### Manifest Processor Lambda
Path: lambdas/manifestProcessor/

Purpose: Processes manifest JSON files

Environment Variables:

STATUS_TABLE: ProcessingStatusTable name

### Classifier Processor Lambda
Path: lambdas/classifierProcessor/

Purpose: Processes classifier JSON files

Environment Variables:

CLASSIFIER_TABLE: EEGClassifierTable name

### Results Metadata Lambda
Path: lambdas/resultsMetadata/

Purpose: Processes metadata JSON files

Environment Variables:

STATUS_TABLE: ProcessingStatusTable name

Status Check Lambda
Path: lambdas/statusCheck/

Purpose: Provides API endpoint for status checks

Environment Variables:

STATUS_TABLE: ProcessingStatusTable name

## Scripts

### Migration Scripts (`scripts/`)

#### migrate-processing-status.js
**Purpose**: Migrates data from old ProcessingStatusTable to ProcessingStatusTableV2
**Usage**: 
```bash
cd scripts
npm install
node migrate-processing-status.js status-data.csv s3-objects.csv
```
**Features**:
- Matches userId/sessionName from status CSV with S3 upload data
- Generates sessionId using same hash function as runtime
- Finds most recent .zip file for each session
- Populates uploadPath field for admin retrigger functionality

#### list-s3-objects.js
**Purpose**: Exports all S3 objects to CSV with path components in separate columns
**Usage**:
```bash
node list-s3-objects.js bucket-name > objects.csv
```
**Output**: CSV with Level1 (userId), Level2 (sessionName), Level3 (fileName), Size, LastModified

### Admin Functions

#### AdminRetriggerLambda
**Purpose**: Reprocess all sessions that have upload data
**Access**: AWS Lambda Console only (no API Gateway routes)
**Usage**:
1. Go to AWS Lambda Console
2. Find `AdminRetriggerLambda` function
3. Click "Test" tab
4. Create test event:
```json
{
  "skipECS": true,
  "userId": "optional-user-filter"
}
```
5. Click "Test" to execute

**Parameters**:
- `skipECS`: `true` to skip ECS processing (testing), `false` for full processing
- `userId`: Optional filter to retrigger only specific user's sessions

**Output**: Returns count of retriggered sessions and detailed results

**Security**: Console-only access ensures only users with AWS Lambda permissions can execute

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
### Get API endpoint from CloudFormation outputs
`
    ENDPOINT=$(aws cloudformation describe-stacks \
    --stack-name AI4NG-EEG-Pipeline \
    --query "Stacks[0].Outputs[?OutputKey=='StatusApiUrl'].OutputValue" \
    --output text)
`
### Call status API
`
    curl -H "Authorization: Bearer YOUR_TOKEN" $ENDPOINT/session456
`
3. Monitor Execution
- View Step Function executions in AWS Console
- Check CloudWatch Logs for each Lambda function
- Monitor ECS tasks in Fargate cluster

## Monitoring and Troubleshooting

### CloudWatch Dashboard
Access the automatically created dashboard via the DashboardUrl output or directly at:
`https://<region>.console.aws.amazon.com/cloudwatch/home?region=<region>#dashboards:name=<stack-name>-EEG-Processing-Pipeline`

The dashboard shows:
- Step Function execution metrics (started, succeeded, failed)
- ECS resource utilization (CPU, memory)
- Lambda performance (duration, errors, invocations)

### CloudWatch Alarms
Three alarms monitor critical failures and send email notifications:
- **Step Function Failures**: Triggers on any failed executions
- **ECS Task Failures**: Monitors stopped tasks
- **Lambda Errors**: Alerts on high error rates (3+ errors in 10 minutes)

### Where to Check for Issues

#### Step Function Failures
1. **AWS Console**: Step Functions → State machines → Select your machine → Executions
2. **CloudWatch Logs**: `/aws/stepfunctions/<stack-name>-ProcessingStateMachine`
3. **DynamoDB**: Check `EEGProcessingStatus` table for failed sessions

#### Lambda Function Issues
1. **CloudWatch Logs**: Each function has its own log group:
   - `/aws/lambda/<stack-name>-S3EventProcessor`
   - `/aws/lambda/<stack-name>-ManifestProcessor`
   - `/aws/lambda/<stack-name>-ClassifierProcessor`
   - `/aws/lambda/<stack-name>-ResultsMetadata`
   - `/aws/lambda/<stack-name>-GetStatus`

#### ECS Task Problems
1. **ECS Console**: Clusters → EEG-Classifier-Cluster → Tasks
2. **CloudWatch Logs**: `/ecs/eeg-classifier`
3. **Task stopped reasons**: Check task details for exit codes and errors

#### EventBridge Rule Issues
1. **EventBridge Console**: Rules → Check rule metrics
2. **CloudWatch Metrics**: AWS/Events namespace
3. **S3 Event Processor Lambda logs**: Verify events are being received

### Common Issues and Solutions

#### Pipeline Not Triggering
- Verify S3 bucket has EventBridge notifications enabled
- Check file path format: `userId/sessionId/filename.zip`
- Ensure file has `.zip` extension
- Check EventBridge rule is enabled

#### ECS Task Failures
- Verify ECR image exists and is accessible
- Check ECS task execution role permissions
- Review container logs for application errors
- Ensure private subnets have NAT gateway access

#### Lambda Timeouts
- Check function timeout settings (30s for processors, 10s for status)
- Review CloudWatch logs for performance bottlenecks
- Monitor memory usage in CloudWatch metrics

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
### Deployment failures:

- Check CloudFormation events for error details

- Verify all parameters are correctly specified

- Ensure ECR image exists before deployment

### Processing failures:

- Check Step Function execution history

- Review CloudWatch logs for Lambda functions

- Verify ECS task has necessary permissions

### API issues:

- Validate JWT token in API requests

- Check API Gateway logs for errors

- Verify DynamoDB table permissions

## Data Flow Summary

1. **Upload**: User uploads .zip file to S3 upload bucket
2. **Trigger**: S3 event triggers S3EventProcessorLambda
3. **Initialize**: Lambda records session in ProcessingStatusTableV2 and starts Step Function
4. **Process**: Step Function launches ECS task to run MATLAB classification
5. **Monitor**: Step Function waits for and processes manifest.json
6. **Extract**: ClassifierProcessorLambda extracts parameters and T1 DA metrics
7. **Complete**: Final status recorded, notifications sent
8. **Query**: Users can check status via REST API
9. **Admin**: Admins can retrigger processing via console Lambda

## Troubleshooting Quick Reference

### Common Issues
- **Step Function not starting**: Check S3 event configuration and Lambda permissions
- **ECS task failures**: Verify ECR image exists and task has proper IAM roles
- **Manifest timeout**: Check ECS logs for MATLAB processing errors
- **Classifier extraction fails**: Verify T1 results file exists and has required DA.smooth fields
- **API 404 errors**: Ensure JWT token is valid and user has proper permissions

### Key Log Locations
- **Step Function**: `/aws/stepfunctions/<stack-name>-ProcessingStateMachine`
- **ECS Container**: `/ecs/eeg-classifier`
- **Lambda Functions**: `/aws/lambda/<stack-name>-<function-name>`

## Support
For assistance, contact the AI4NG team at hss70@bath.ac.uk