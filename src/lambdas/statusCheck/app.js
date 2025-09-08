const { DynamoDBClient, QueryCommand, ScanCommand } = require("@aws-sdk/client-dynamodb");
const { CloudWatchLogsClient, FilterLogEventsCommand } = require("@aws-sdk/client-cloudwatch-logs");
const { unmarshall } = require("@aws-sdk/util-dynamodb");

const ddbClient = new DynamoDBClient();
const logsClient = new CloudWatchLogsClient();
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
    
    // Add ECS logs if available
    if (statusInfo.status === 'PROCESSING' || statusInfo.status === 'FAILED') {
        statusInfo.logs = await getECSLogs(sessionId);
    }
    
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
    // Parse startTime - could be ISO string or Unix timestamp
    let startTimeUnix = 0;
    let startTimeISO = '';
    
    if (item.startTime) {
        if (typeof item.startTime === 'string' && item.startTime.includes('T')) {
            // ISO string format like "2025-08-20T12:48:20.387Z"
            const date = new Date(item.startTime);
            startTimeUnix = Math.floor(date.getTime() / 1000);
            startTimeISO = item.startTime;
        } else {
            // Unix timestamp or number
            startTimeUnix = parseInt(item.startTime);
            startTimeISO = new Date(startTimeUnix * 1000).toISOString();
        }
    }
    
    const statusInfo = {
        sessionName: item.sessionName || '',
        sessionId: sessionId || item.sessionId || 0,
        status: item.status || 'UNKNOWN',
        userId: item.userId || '',
        startTime: startTimeUnix,
        processingDuration: parseInt(item.processingDuration) || 0,
        resultsPath: item.resultsPath || '',
        exitCode: parseInt(item.exitCode) || -1,
        startTimeISO: startTimeISO
    };
    
    return statusInfo;
}

async function getECSLogs(sessionId) {
    try {
        const params = {
            logGroupName: '/ecs/eeg-classifier',
            filterPattern: `"[SESSION_ID=${sessionId}]"`,
            logStreamNamePrefix: `session-${sessionId}`,
            limit: 50,
            startTime: Date.now() - (24 * 60 * 60 * 1000) // Last 24 hours
        };
        
        const response = await logsClient.send(new FilterLogEventsCommand(params));
        
        return response.events?.map(event => ({
            timestamp: new Date(event.timestamp).toISOString(),
            message: event.message?.trim()
        })) || [];
    } catch (error) {
        console.error('Error fetching ECS logs:', error);
        return [];
    }
}