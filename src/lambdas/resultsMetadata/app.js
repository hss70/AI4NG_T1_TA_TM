const { DynamoDBClient, UpdateItemCommand } = require("@aws-sdk/client-dynamodb");
const { S3Client, HeadObjectCommand } = require("@aws-sdk/client-s3");

const ddbClient = new DynamoDBClient();
const s3Client = new S3Client();

exports.handler = async (event) => {
    try {
        await Promise.all(event.Records.map(processRecord));
        return { statusCode: 200, body: 'Processed successfully' };
    } catch (error) {
        console.error('Handler error:', error);
        return { statusCode: 500, body: 'Processing failed' };
    }
};

async function processRecord(record) {
    try {
        const bucket = record.s3.bucket.name;
        const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, ' '));
        
        // Skip directory markers
        if (key.endsWith('/')) return;
        
        // Extract path components
        const pathParts = key.split('/');
        if (pathParts.length < 4) return;
        
        const userId = pathParts[0];
        const sessionId = pathParts[1];
        const fileName = pathParts[pathParts.length - 1];
        
        // Get file metadata (optional - remove if not needed)
        await s3Client.send(new HeadObjectCommand({
            Bucket: bucket,
            Key: key
        }));
        
        // Update DynamoDB
        await ddbClient.send(new UpdateItemCommand({
            TableName: process.env.STATUS_TABLE,
            Key: { sessionId: { S: sessionId } },
            UpdateExpression: "ADD files :file SET lastUpdated = :now",
            ExpressionAttributeValues: {
                ":file": { SS: [key] },
                ":now": { N: Math.floor(Date.now() / 1000).toString() }
            }
        }));
        
        console.log(`Metadata updated for: ${key}`);
    } catch (error) {
        console.error(`Error processing record: ${error.message}`);
    }
}