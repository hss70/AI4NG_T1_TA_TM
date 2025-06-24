const AWS = require('aws-sdk');
const stepFunctions = new AWS.StepFunctions();

exports.handler = async (event) => {
    try {
        console.log('Received EventBridge event:', JSON.stringify(event, null, 2));
        
        // Extract bucket and key from EventBridge format
        const bucket = event.detail.bucket.name;
        const key = decodeURIComponent(event.detail.object.key.replace(/\+/g, ' '));
        
        console.log(`Processing EEG upload: ${bucket}/${key}`);
        
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
        console.log(`Started Step Function execution: ${response.executionArn}`);
        
        return {
            statusCode: 200,
            body: JSON.stringify({ message: 'Processing initiated successfully' })
        };
    } catch (error) {
        console.error('Error processing event:', error);
        
        return {
            statusCode: 500,
            body: JSON.stringify({ 
                message: 'Failed to process upload', 
                error: error.message 
            })
        };
    }
};