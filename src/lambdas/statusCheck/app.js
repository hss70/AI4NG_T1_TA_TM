const { DynamoDBClient, QueryCommand, ScanCommand } = require("@aws-sdk/client-dynamodb");
const { unmarshall } = require("@aws-sdk/util-dynamodb");

const ddbClient = new DynamoDBClient();
const tableName = process.env.STATUS_TABLE;

exports.handler = async (event) => {
    try {
        const path = event.routeKey;
        const queryParams = event.queryStringParameters || {};
        
        // Route to appropriate handler
        if (path === 'GET /api/status') {
            return await getAllSessions(queryParams);
        } else if (path === 'GET /api/status/{sessionId}') {
            const sessionId = parseInt(event.pathParameters.sessionId);
            return await getSessionById(sessionId);
        }
        
        return {
            statusCode: 404,
            body: JSON.stringify({ error: 'Route not found' })
        };
        
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: error.message })
        };
    }
};

async function getSessionById(sessionId) {
    const params = {
        TableName: tableName,
        IndexName: 'SessionIdIndex',
        KeyConditionExpression: 'sessionId = :sessionId',
        ExpressionAttributeValues: {
            ':sessionId': { N: sessionId.toString() }
        },
        Limit: 1
    };
    
    const response = await ddbClient.send(new QueryCommand(params));
    
    if (!response.Items || response.Items.length === 0) {
        return {
            statusCode: 404,
            body: JSON.stringify({ error: 'Session not found' })
        };
    }
    
    const item = unmarshall(response.Items[0]);
    const statusInfo = formatStatusItem(item, sessionId);
    
    return {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(statusInfo)
    };
}

async function getAllSessions(queryParams) {
    const status = queryParams.status;
    let params;
    
    if (status) {
        // Filter by status
        params = {
            TableName: tableName,
            FilterExpression: '#status = :status',
            ExpressionAttributeNames: {
                '#status': 'status'
            },
            ExpressionAttributeValues: {
                ':status': { S: status }
            }
        };
    } else {
        // Get all sessions
        params = {
            TableName: tableName
        };
    }
    
    const response = await ddbClient.send(new ScanCommand(params));
    
    const sessions = response.Items.map(item => {
        const unmarshalled = unmarshall(item);
        return formatStatusItem(unmarshalled, unmarshalled.sessionId);
    });
    
    return {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ sessions, count: sessions.length })
    };
}

function formatStatusItem(item, sessionId) {
    const statusInfo = {
        sessionName: item.sessionName || '',
        sessionId: sessionId || item.sessionId || 0,
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
    
    return statusInfo;
}