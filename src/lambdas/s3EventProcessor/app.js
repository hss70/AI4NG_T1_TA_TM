const AWS = require('aws-sdk');
const stepFunctions = new AWS.StepFunctions();

exports.handler = async (event) => {
    try {
        console.log('Received S3 event:', JSON.stringify(event, null, 2));
        
        // Process each record in the event
        for (const record of event.Records) {
            if (record.eventSource !== 'aws:s3') {
                console.log('Skipping non-S3 event');
                continue;
            }
            
            const bucket = record.s3.bucket.name;
            const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, ' '));
            
            // Validate it's a .zip file in the uploads folder
            if (!key.startsWith('uploads/') || !key.endsWith('.zip')) {
                console.log(`Skipping non-zip file: ${key}`);
                continue;
            }
            
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
                name: `exec-${Date.now()}-${key.replace(/\//g, '-')}`
            };
            
            const response = await stepFunctions.startExecution(params).promise();
            console.log(`Started Step Function execution: ${response.executionArn}`);
        }
        
        return {
            statusCode: 200,
            body: JSON.stringify({ message: 'Processing initiated successfully' })
        };
    } catch (error) {
        console.error('Error processing S3 event:', error);
        
        return {
            statusCode: 500,
            body: JSON.stringify({ 
                message: 'Failed to process upload', 
                error: error.message 
            })
        };
    }
};