const { S3Client, GetObjectCommand } = require("@aws-sdk/client-s3");
const { DynamoDBClient, UpdateItemCommand } = require("@aws-sdk/client-dynamodb");
const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");
const { Readable } = require('stream');

const s3Client = new S3Client();
const ddbClient = new DynamoDBClient();
const snsClient = new SNSClient();

exports.handler = async (event) => {
    try {
        // Handle Step Function input format
        if (event.s3Bucket && event.s3Key) {
            const result = await processManifestFromStepFunction(event.s3Bucket, event.s3Key);
            return result;
        }
        // Handle S3 event format
        if (event.Records) {
            await Promise.all(event.Records.map(processManifestRecord));
            return { status: 'success', processed: event.Records.length };
        }
        throw new Error('Invalid event format');
    } catch (error) {
        console.error('Handler error:', error);
        throw error;
    }
};

async function processManifestRecord(record) {
    const bucket = record.s3.bucket.name;
    const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, ' '));
    
    try {
        // Get manifest file from S3
        const { Body } = await s3Client.send(new GetObjectCommand({
            Bucket: bucket,
            Key: key
        }));
        
        // Convert stream to string
        const manifestJson = await streamToString(Body);
        const manifest = JSON.parse(manifestJson);
        
        // Extract path components
        const pathParts = key.split('/');
        const userId = pathParts[0];
        const sessionId = pathParts[1];
        
        // Calculate processing duration
        const processingDuration = manifest.endTime - manifest.startTime;
        const status = manifest.exitCode === 0 ? 'COMPLETED' : 'FAILED';
        
        // Update DynamoDB status
        await updateStatusTable(sessionId, userId, status, processingDuration, manifest);
        
        // Store file metadata
        await storeFileMetadata(sessionId, userId, manifest);
        
        // Send SNS notification
        await sendNotification(manifest, status, userId, sessionId);
        
        console.log(`Processed manifest for session: ${sessionId}, status: ${status}`);
    } catch (error) {
        console.error(`Error processing manifest ${key}: ${error.message}`);
        throw error;
    }
}

async function updateStatusTable(sessionId, userId, status, duration, manifest) {
    const updateParams = {
        TableName: process.env.STATUS_TABLE,
        Key: { sessionId: { S: sessionId } },
        UpdateExpression: "SET #s = :status, userId = :userId, endTime = :endTime, " +
                         "processingDuration = :duration, resultsPath = :resultsPath, " +
                         "exitCode = :exitCode",
        ExpressionAttributeNames: { "#s": "status" },
        ExpressionAttributeValues: {
            ":status": { S: status },
            ":userId": { S: userId },
            ":endTime": { N: manifest.endTime.toString() },
            ":duration": { N: duration.toString() },
            ":resultsPath": { S: manifest.resultsPath },
            ":exitCode": { N: manifest.exitCode.toString() }
        }
    };
    
    await ddbClient.send(new UpdateItemCommand(updateParams));
}

async function storeFileMetadata(sessionId, userId, manifest) {
    const { PutItemCommand } = require("@aws-sdk/client-dynamodb");
    
    for (const file of manifest.outputFiles) {
        const fullPath = `${userId}/${sessionId}/${file}`;
        
        await ddbClient.send(new PutItemCommand({
            TableName: process.env.FILES_TABLE,
            Item: {
                sessionId: { S: sessionId },
                filePath: { S: fullPath },
                fileName: { S: file },
                userId: { S: userId },
                createdAt: { N: manifest.endTime.toString() }
            }
        }));
    }
}

async function sendNotification(manifest, status, userId, sessionId) {
    const message = {
        userId,
        sessionId,
        status,
        inputFile: manifest.inputFile,
        startTime: new Date(manifest.startTime * 1000).toISOString(),
        processingDuration: `${manifest.endTime - manifest.startTime} seconds`,
        resultsPath: manifest.resultsPath,
        exitCode: manifest.exitCode,
        outputFiles: manifest.outputFiles
    };
    
    const command = new PublishCommand({
        TopicArn: process.env.SNS_TOPIC_ARN,
        Message: JSON.stringify(message),
        Subject: `EEG Processing ${status} - Session: ${sessionId}`
    });
    
    await snsClient.send(command);
}

async function processManifestFromStepFunction(bucket, key) {
    try {
        // Get manifest file from S3
        const { Body } = await s3Client.send(new GetObjectCommand({
            Bucket: bucket,
            Key: key
        }));
        
        const manifestJson = await streamToString(Body);
        const manifest = JSON.parse(manifestJson);
        
        // Extract path components
        const pathParts = key.split('/');
        const userId = pathParts[0];
        const sessionId = pathParts[1];
        
        // Calculate processing duration
        const processingDuration = manifest.endTime - manifest.startTime;
        const status = manifest.exitCode === 0 ? 'COMPLETED' : 'FAILED';
        
        // Update DynamoDB status
        await updateStatusTable(sessionId, userId, status, processingDuration, manifest);
        
        // Store file metadata
        await storeFileMetadata(sessionId, userId, manifest);
        
        // Send SNS notification
        await sendNotification(manifest, status, userId, sessionId);
        
        // Check if metadata file actually exists if manifest claims it has metadata
        let hasMetadata = manifest.hasMetadata || false;
        if (hasMetadata && manifest.metadataFile) {
            try {
                await s3Client.send(new GetObjectCommand({
                    Bucket: bucket,
                    Key: `${userId}/${sessionId}/${manifest.metadataFile}`
                }));
            } catch (error) {
                console.log(`Metadata file ${manifest.metadataFile} not found, setting hasMetadata to false`);
                hasMetadata = false;
            }
        }
        
        return {
            requiresClassifier: true,
            hasMetadata,
            classifierFile: `Online/${userId}/${sessionId}/FBCSP_online_setup_prep_01 [online].json`,
            metadataFile: manifest.metadataFile || null
        };
    } catch (error) {
        console.error(`Error processing manifest ${key}: ${error.message}`);
        throw error;
    }
}

function streamToString(stream) {
    return new Promise((resolve, reject) => {
        const chunks = [];
        stream.on('data', (chunk) => chunks.push(chunk));
        stream.on('error', reject);
        stream.on('end', () => resolve(Buffer.concat(chunks).toString('utf8')));
    });
}