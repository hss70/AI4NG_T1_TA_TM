const { S3Client, GetObjectCommand } = require("@aws-sdk/client-s3");
const { DynamoDBClient, UpdateItemCommand } = require("@aws-sdk/client-dynamodb");
const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");
const { Readable } = require('stream');

const s3Client = new S3Client();
const ddbClient = new DynamoDBClient();
const snsClient = new SNSClient();

exports.handler = async (event) => {
    try {
        console.log(JSON.stringify({ level: 'INFO', message: 'Handler started', event }));
        
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
        console.error(JSON.stringify({ level: 'ERROR', message: 'Handler error', error: error.message }));
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
        const sessionName = pathParts[1];
        
        // Generate consistent sessionId from userId + sessionName
        const sessionId = Math.abs((userId + sessionName).split('').reduce((a, b) => {
            a = ((a << 5) - a) + b.charCodeAt(0);
            return a & a;
        }, 0));
        
        // Calculate processing duration
        const processingDuration = manifest.endTime - manifest.startTime;
        const status = manifest.exitCode === 0 ? 'COMPLETED' : 'FAILED';
        
        // Update DynamoDB status
        await updateStatusTable(sessionName, sessionId, userId, status, processingDuration, manifest);
        
        // Store file metadata
        await storeFileMetadata(sessionName, sessionId, userId, manifest);
        
        // Send SNS notification
        await sendNotification(manifest, status, userId, sessionName, sessionId);
        
        console.log(JSON.stringify({ 
            level: 'INFO', 
            message: 'Manifest processed', 
            sessionId, 
            sessionName, 
            userId, 
            status,
            processingDuration 
        }));
    } catch (error) {
        console.error(JSON.stringify({ 
            level: 'ERROR', 
            message: 'Manifest processing failed', 
            sessionId: sessionId || 'unknown',
            sessionName: sessionName || 'unknown',
            userId: userId || 'unknown',
            key, 
            error: error.message 
        }));
        throw error;
    }
}

async function updateStatusTable(sessionName, sessionId, userId, status, duration, manifest) {
    const updateParams = {
        TableName: process.env.STATUS_TABLE,
        Key: { sessionId: { N: sessionId.toString() } },
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

async function storeFileMetadata(sessionName, sessionId, userId, manifest) {
    const { UpdateItemCommand } = require("@aws-sdk/client-dynamodb");
    
    for (const file of manifest.outputFiles) {
        const fullPath = `${userId}/${sessionId}/${file}`;
        
        await ddbClient.send(new UpdateItemCommand({
            TableName: process.env.FILES_TABLE,
            Key: {
                sessionId: { N: sessionId.toString() },
                filePath: { S: fullPath }
            },
            UpdateExpression: "SET fileName = :fileName, userId = :userId, createdAt = :createdAt, sessionName = :sessionName",
            ExpressionAttributeValues: {
                ":fileName": { S: file },
                ":userId": { S: userId },
                ":createdAt": { N: manifest.endTime.toString() },
                ":sessionName": { S: sessionName }
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
        const sessionName = pathParts[1];
        
        // Generate consistent sessionId from userId + sessionName
        const sessionId = Math.abs((userId + sessionName).split('').reduce((a, b) => {
            a = ((a << 5) - a) + b.charCodeAt(0);
            return a & a;
        }, 0));
        
        // Calculate processing duration
        const processingDuration = manifest.endTime - manifest.startTime;
        const status = manifest.exitCode === 0 ? 'COMPLETED' : 'FAILED';
        
        // Update DynamoDB status
        await updateStatusTable(sessionName, sessionId, userId, status, processingDuration, manifest);
        
        // Store file metadata
        await storeFileMetadata(sessionName, sessionId, userId, manifest);
        
        // Send SNS notification
        await sendNotification(manifest, status, userId, sessionName, sessionId);
        
        // Check if metadata file actually exists if manifest claims it has metadata
        let hasMetadata = manifest.hasMetadata || false;
        if (hasMetadata && manifest.metadataFile) {
            try {
                await s3Client.send(new GetObjectCommand({
                    Bucket: bucket,
                    Key: `${userId}/${sessionId}/${manifest.metadataFile}`
                }));
            } catch (error) {
                console.log(JSON.stringify({ 
                level: 'WARN', 
                message: 'Metadata file not found', 
                sessionId, 
                sessionName, 
                userId,
                metadataFile: manifest.metadataFile 
            }));
                hasMetadata = false;
            }
        }
        
        return {
            requiresClassifier: true,
            hasMetadata,
            classifierFile: `Online/${userId}/${sessionName}/FBCSP_online_setup_prep_01 [online].json`,
            metadataFile: manifest.metadataFile || null
        };
    } catch (error) {
        console.error(JSON.stringify({ 
            level: 'ERROR', 
            message: 'Step function manifest processing failed', 
            sessionId: sessionId || 'unknown',
            sessionName: sessionName || 'unknown', 
            userId: userId || 'unknown',
            key, 
            error: error.message 
        }));
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