S3EventProcessorLambda
Purpose: Triggered by S3 upload events, starts Step Function execution

Trigger: S3 ObjectCreated:* on EEGUploadBucket (filter: .zip files)

Input: S3 event payload

Output: Starts Step Function execution with event data

Permissions:

s3:GetObject on upload bucket

states:StartExecution on Step Function

Environment Variables:

STATE_MACHINE_ARN: ARN of processing state machine