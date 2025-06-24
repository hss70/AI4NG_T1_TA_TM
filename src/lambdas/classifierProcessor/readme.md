classifierProcessorLambda
Purpose: Process classifier JSON files

Trigger: Conditionally invoked by Step Function

Input:

json
{
  "s3Bucket": "results-bucket",
  "s3Key": "user123/session456/analysis/classifier_v2.json"
}
Output: Success/failure status

Permissions:

s3:GetObject on results bucket

dynamodb:PutItem on classifier table