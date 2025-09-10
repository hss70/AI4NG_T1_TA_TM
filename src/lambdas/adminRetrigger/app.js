const AWS = require('aws-sdk');
const stepFunctions = new AWS.StepFunctions();
const dynamodb = new AWS.DynamoDB();

exports.handler = async (event) => {
    try {
        const { skipECS = false, userId = null } = event;
        
        // Get all sessions from processing status table
        const scanParams = {
            TableName: process.env.STATUS_TABLE
        };
        
        if (userId) {
            scanParams.FilterExpression = 'userId = :userId';
            scanParams.ExpressionAttributeValues = { ':userId': { S: userId } };
        }
        
        const sessions = await dynamodb.scan(scanParams).promise();
        const results = [];
        
        for (const item of sessions.Items) {
            if (!item.uploadPath || !item.bucket) continue;
            
            try {
                const input = {
                    detail: {
                        bucket: { name: item.bucket.S },
                        object: { key: item.uploadPath.S }
                    },
                    skipECS
                };
                
                const response = await stepFunctions.startExecution({
                    stateMachineArn: process.env.STATE_MACHINE_ARN,
                    input: JSON.stringify(input),
                    name: `retrigger-${Date.now()}-${item.uploadPath.S.replace(/\//g, '-').slice(0, 40)}`
                }).promise();
                
                results.push({
                    sessionName: item.sessionName.S,
                    uploadPath: item.uploadPath.S,
                    status: 'RETRIGGERED',
                    executionArn: response.executionArn
                });
            } catch (error) {
                results.push({
                    sessionName: item.sessionName.S,
                    uploadPath: item.uploadPath?.S || 'unknown',
                    status: 'FAILED',
                    error: error.message
                });
            }
        }
        
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: `Retriggered ${results.filter(r => r.status === 'RETRIGGERED').length} uploads`,
                skipECS,
                results
            })
        };
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({ error: error.message })
        };
    }
};