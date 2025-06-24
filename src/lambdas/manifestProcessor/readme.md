manifestProcessorLambda
Purpose: Process manifest files, determine processing requirements

Trigger: Invoked by Step Function

Input:

json
{
  "s3Bucket": "results-bucket",
  "s3Key": "user123/session456/manifest.json"
}
Output:

json
{
  "requiresClassifier": true,
  "hasMetadata": true,
  "classifierFile": "analysis/classifier_v2.json",
  "metadataFile": "results/metadata.json"
}
Permissions:

s3:GetObject on results bucket

dynamodb:UpdateItem on status table