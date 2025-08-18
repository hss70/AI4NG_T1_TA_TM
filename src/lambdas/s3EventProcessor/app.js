const AWS = require('aws-sdk');
const stepFunctions = new AWS.StepFunctions();

exports.handler = async (event) => {
    try {
        const bucket = event.detail.bucket.name;
        const key = decodeURIComponent(event.detail.object.key.replace(/\+/g, ' '));
        const pathParts = key.split('/');
        const userId = pathParts[0] || 'unknown';
        const sessionName = pathParts[1] || 'unknown';
        const sessionId = Math.abs((userId + sessionName).split('').reduce((a, b) => {
            a = ((a << 5) - a) + b.charCodeAt(0);
            return a & a;
        }, 0));
        
        console.log(JSON.stringify({ 
            level: 'INFO', 
            message: 'S3 event received', 
            sessionId, 
            sessionName, 
            userId, 
            bucket, 
            key 
        }));
        
        // Prepare Step Function input
        const input = {
            detail: {
                bucket: { name: bucket },
                object: { key }
            }
        };
        
        // Start Step Function execution
        const params = {
            stateMachineArn: process.env.STATE_MACHINE_ARN,
            input: JSON.stringify(input),
            name: `exec-${Date.now()}-${key.replace(/\//g, '-').slice(0, 40)}`
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