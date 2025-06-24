const { DynamoDBClient, GetItemCommand } = require("@aws-sdk/client-dynamodb");
const { unmarshall } = require("@aws-sdk/util-dynamodb");

const ddbClient = new DynamoDBClient();
const tableName = process.env.STATUS_TABLE;

exports.handler = async (event) => {
    try {
        // Extract session ID from path parameters
        const sessionId = event.pathParameters.sessionId;
        
        // Get status from DynamoDB
        const params = {
            TableName: tableName,
            Key: { sessionId: { S: sessionId } }
        };
        
        const response = await ddbClient.send(new GetItemCommand(params));
        
        if (!response.Item) {
            return {
                statusCode: 404,
                body: JSON.stringify({ error: 'Session not found' })
            };
        }
        
        // Unmarshall DynamoDB item to plain JS object
        const item = unmarshall(response.Item);
        
        // Prepare response
        const statusInfo = {
            sessionId: sessionId,
            status: item.status || 'UNKNOWN',
            userId: item.userId || '',
            startTime: parseInt(item.startTime) || 0,
            processingDuration: parseInt(item.processingDuration) || 0,
            resultsPath: item.resultsPath || '',
            exitCode: parseInt(item.exitCode) || -1
        };
        
        // Add human-readable timestamp
        if (item.startTime) {
            statusInfo.startTimeISO = new Date(parseInt(item.startTime) * 1000)
                .toISOString()
                .replace(/\.\d{3}Z$/, 'Z');  // Trim milliseconds
        }
        
        return {
            statusCode: 200,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(statusInfo)
        };
        
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: error.message })
        };
    }
};