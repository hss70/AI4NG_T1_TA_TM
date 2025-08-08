const { S3Client, GetObjectCommand } = require("@aws-sdk/client-s3");
const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const { Readable } = require('stream');

const s3Client = new S3Client();
const ddbClient = new DynamoDBClient();

exports.handler = async (event) => {
    try {
        // Handle direct Step Function invocation
        if (event.s3Bucket && event.s3Key) {
            await processDirectInvocation(event);
            return { status: 'success' };
        }
        
        // Handle S3 event records (legacy)
        if (event.Records) {
            await Promise.all(event.Records.map(processRecord));
            return { status: 'success', processed: event.Records.length };
        }
        
        throw new Error('Invalid event format');
    } catch (error) {
        console.error('Handler error:', error);
        throw error;
    }
};

async function processDirectInvocation(event) {
    const bucket = event.s3Bucket;
    const key = event.s3Key;
    
    // Validate path format: userId/sessionId/Online/userId/sessionId/filename.json
    const pathParts = key.split('/');
    if (pathParts.length < 6 || pathParts[2] !== 'Online') {
        console.log(`Skipping invalid path: ${key}`);
        return;
    }
    
    const userId = pathParts[0];
    const sessionId = pathParts[1];
    const fileName = pathParts[pathParts.length - 1];
    
    try {
        // Get JSON file from S3
        const { Body } = await s3Client.send(new GetObjectCommand({
            Bucket: bucket,
            Key: key
        }));
        
        // Convert stream to string
        const jsonString = await streamToString(Body);
        const jsonData = JSON.parse(jsonString);
        
        // Extract critical parameters
        const params = extractParameters(jsonData);
        
        // Prepare DynamoDB item
        const dbItem = {
            sessionId: { S: sessionId },
            userId: { S: userId },
            timestamp: { N: Date.now().toString() },
            fileName: { S: fileName },
            s3Key: { S: key },
            ...params
        };
        
        // Write to DynamoDB
        await ddbClient.send(new PutItemCommand({
            TableName: process.env.CLASSIFIER_TABLE,
            Item: dbItem
        }));
        
        console.log(`Processed session ${sessionId}, file: ${fileName}`);
    } catch (error) {
        console.error(`Error processing ${key}: ${error.message}`);
        throw error;
    }
}

async function processRecord(record) {
    const bucket = record.s3.bucket.name;
    const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, ' '));
    
    // Validate path format: userId/sessionId/Online/userId/sessionId/filename.json
    const pathParts = key.split('/');
    if (pathParts.length < 6 || pathParts[2] !== 'Online') {
        console.log(`Skipping invalid path: ${key}`);
        return;
    }
    
    const userId = pathParts[0];
    const sessionId = pathParts[1];
    const fileName = pathParts[pathParts.length - 1];
    
    try {
        // Get JSON file from S3
        const { Body } = await s3Client.send(new GetObjectCommand({
            Bucket: bucket,
            Key: key
        }));
        
        // Convert stream to string
        const jsonString = await streamToString(Body);
        const jsonData = JSON.parse(jsonString);
        
        // Extract critical parameters
        const params = extractParameters(jsonData);
        
        // Prepare DynamoDB item
        const dbItem = {
            sessionId: { S: sessionId },
            userId: { S: userId },
            timestamp: { N: Date.now().toString() },
            fileName: { S: fileName },
            s3Key: { S: key },
            ...params
        };
        
        // Write to DynamoDB
        await ddbClient.send(new PutItemCommand({
            TableName: process.env.CLASSIFIER_TABLE,
            Item: dbItem
        }));
        
        console.log(`Processed session ${sessionId}, file: ${fileName}`);
    } catch (error) {
        console.error(`Error processing ${key}: ${error.message}`);
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

function extractParameters(data) {
    const p = data.online?.p;
    if (!p) throw new Error('Missing parameters in JSON');
    
    const result = {};
    
    // EEG parameters (required)
    if (p.EEG) {
        result.eeg = { 
            M: {
                rec: { M: mapToDynamo(p.EEG.rec || {}) },
                bandPass: { M: mapToDynamo(p.EEG.bandPass || {}) }
            }
        };
    }
    
    // CSP parameters (handle empty arrays)
    if (p.CSP?.filters_used) {
        result.csp = { 
            M: {
                filters_used: { L: p.CSP.filters_used.map(arr => {
                    if (!Array.isArray(arr) || arr.length === 0) {
                        return { L: [] };
                    }
                    return {
                        L: arr.map(sub => ({
                            L: sub.map(n => ({ N: n.toString() }))
                        }))
                    };
                }) }
            }
        };
    }
    
    // CF parameters (optional)
    if (p.CF) {
        result.cf = {
            M: {
                winSize: { M: mapToDynamo(p.CF.winSize || {}) },
                param: { M: mapToDynamo(p.CF.param || {}) }
            }
        };
    }
    
    // MI parameters (optional)
    if (p.MI?.out_usedFeatureIDs) {
        result.mi = {
            M: {
                out_usedFeatureIDs: { L: p.MI.out_usedFeatureIDs.map(arr => ({
                    L: Array.isArray(arr) ? arr.map(n => ({ N: n.toString() })) : []
                })) }
            }
        };
    }
    
    return result;
}

// Helper to convert JS objects to DynamoDB attribute values
function mapToDynamo(obj) {
    const result = {};
    for (const [key, value] of Object.entries(obj)) {
        if (Array.isArray(value)) {
            result[key] = { L: value.map(item => {
                if (typeof item === 'number') return { N: item.toString() };
                if (typeof item === 'string') return { S: item };
                return { NULL: true };
            })};
        } else if (typeof value === 'object' && value !== null) {
            result[key] = { M: mapToDynamo(value) };
        } else if (typeof value === 'number') {
            result[key] = { N: value.toString() };
        } else if (typeof value === 'string') {
            result[key] = { S: value };
        }
    }
    return result;
}