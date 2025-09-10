const AWS = require('aws-sdk');
const stepFunctions = new AWS.StepFunctions();
const dynamodb = new AWS.DynamoDB();

exports.handler = async (event) => {
    try {
        const bucket = event.detail.bucket.name;
        const key = decodeURIComponent(event.detail.object.key.replace(/\+/g, ' '));
        const pathParts = key.split('/');
        const userId = pathParts[0] || 'unknown';
        const sessionName = pathParts[1] || 'unknown';
        const sessionId = generateSessionId(userId, sessionName);

        console.log(JSON.stringify({
            level: 'INFO',
            message: 'S3 event received',
            sessionId,
            sessionName,
            userId,
            bucket,
            key
        }));

        // Record upload in processing status table
        await dynamodb.updateItem({
            TableName: process.env.STATUS_TABLE,
            Key: {
                sessionId: { N: sessionId.toString() }
            },
            UpdateExpression: "SET sessionName = :sessionName, userId = :userId, #s = :status, startTime = :startTime, uploadPath = :uploadPath, bucket = :bucket",
            ExpressionAttributeNames: {
                "#s": "status"
            },
            ExpressionAttributeValues: {
                ":sessionName": { S: sessionName },
                ":userId": { S: userId },
                ":status": { S: 'TRIGGERED' },
                ":startTime": { S: new Date().toISOString() },
                ":uploadPath": { S: key },
                ":bucket": { S: bucket }
            }
        }).promise();

        // Prepare Step Function input
        const input = {
            detail: {
                bucket: { name: bucket },
                object: { key },
                sessionId: sessionId.toString()
            }
        };

        // Start Step Function execution
        const params = {
            stateMachineArn: process.env.STATE_MACHINE_ARN,
            input: JSON.stringify(input),
            name: `exec-${Date.now()}-${sessionId}-${key.replace(/\//g, '-').slice(0, 40)}`
        };

        const response = await stepFunctions.startExecution(params).promise();

        console.log(JSON.stringify({
            level: 'INFO',
            message: 'Step Function started',
            sessionId,
            sessionName,
            userId,
            executionArn: response.executionArn
        }));

        return {
            statusCode: 200,
            body: JSON.stringify({ message: 'Processing initiated successfully' })
        };
    } catch (error) {
        console.error(JSON.stringify({
            level: 'ERROR',
            message: 'S3 event processing failed',
            error: error.message
        }));

        return {
            statusCode: 500,
            body: JSON.stringify({
                message: 'Failed to process upload',
                error: error.message
            })
        };
    }
};

function generateSessionId(userId, sessionName) {
    if (!userId || !sessionName) {
        throw new Error('userId and sessionName are required');
    }

    // JavaScript implementation of the C# hash function
    const combined = userId + sessionName;
    let hash = 0;

    for (let i = 0; i < combined.length; i++) {
        const char = combined.charCodeAt(i);
        hash = ((hash << 5) - hash) + char;
        hash = hash & hash; // Convert to 32-bit integer
    }

    return Math.abs(hash);
};