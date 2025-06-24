getStatusLambda
Purpose: Provide API endpoint for processing status

Trigger: API Gateway GET /status/{sessionId}

Input: sessionId path parameter

Output: Processing status from DynamoDB

Permissions: dynamodb:GetItem on status table