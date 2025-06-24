resultsMetadataLambda
Purpose: Process metadata JSON files

Trigger: Conditionally invoked by Step Function

Input:

json
{
  "s3Bucket": "results-bucket",
  "s3Key": "user123/session456/results/metadata.json"
}
Output: Success/failure status

Permissions:

s3:GetObject on results bucket

dynamodb:UpdateItem on status table