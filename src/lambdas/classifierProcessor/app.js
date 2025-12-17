const { S3Client, GetObjectCommand } = require("@aws-sdk/client-s3");
const { DynamoDBClient, UpdateItemCommand } = require("@aws-sdk/client-dynamodb");
const { Readable } = require('stream');
const { json } = require("stream/consumers");

const s3Client = new S3Client();
const ddbClient = new DynamoDBClient();

exports.handler = async (event) => {
    try {
        console.log(JSON.stringify({ level: 'INFO', message: 'Classifier handler started', event }));

        // Handle direct Step Function invocation
        if (event.s3Bucket && (event.s3Key || event.s3KeyClassifierFile) && event.sessionId) {
            await processDirectInvocation(event);
            return { status: 'success' };
        }

        throw new Error('Invalid event format');
    } catch (error) {
        console.error(JSON.stringify({ level: 'ERROR', message: 'Classifier handler error', error: error.message }));
        throw error;
    }
};

async function processDirectInvocation(event) {
    const bucket = event.s3Bucket;
    const classifierKey = event.s3KeyClassifierFile || event.s3Key; // backward compatibility
    const resultsKey = event.s3KeyResultsFile;
    await processClassifierFile(bucket, classifierKey, resultsKey, event.sessionId);
}

async function processClassifierFile(bucket, classifierKey, resultsKey = null, sessionId) {
    // Validate path format: userId/sessionName/Online/userId/sessionName/filename.json
    const pathParts = classifierKey.split('/');
    if (pathParts.length < 6 || pathParts[2] !== 'Online') {
        console.log(JSON.stringify({ level: 'WARN', message: 'Invalid path format', key: classifierKey }));
        return;
    }

    const userId = pathParts[0];
    const sessionName = pathParts[1];
    const fileName = pathParts[pathParts.length - 1];

    try {
        // Get JSON file from S3
        const { Body } = await s3Client.send(new GetObjectCommand({
            Bucket: bucket,
            Key: classifierKey
        }));

        // Convert stream to string
        const jsonString = await streamToString(Body);
        const jsonData = JSON.parse(jsonString);

        // Extract critical parameters
        const params = extractParameters(jsonData);

        const classifierId = Date.now() + Math.floor(Math.random() * 1000);

        // Fetch T1 results for DA metrics
        const t1Results = resultsKey ?
            await fetchT1ResultsFromKey(bucket, resultsKey) :
            await fetchT1Results(bucket, userId, sessionName);

        const t1ResultsTable =
            await fetchT1ResultsTable(bucket, userId, sessionName);
        
        console.log(JSON.stringify({
            level: 'INFO',
            message: 'T1 data fetched',
            hasT1ResultsTable: !!t1ResultsTable,
            hasT1ResultsTableData: !!t1ResultsTable?.t1ResultsTableData,
            t1ResultsTableKeys: t1ResultsTable ? Object.keys(t1ResultsTable) : []
        }));

        // Store in DynamoDB
        const updateExpression = [];
        const expressionAttributeValues = {
            ":sessionId": { N: sessionId.toString() },
            ":userId": { S: userId },
            ":sessionName": { S: sessionName },
            ":timestamp": { N: Date.now().toString() },
            ":fileName": { S: fileName },
            ":s3Key": { S: classifierKey },
            ":peakAccuracy": { N: t1Results.taskPeakDA_mean.toString() },
            ":errorMargin": { N: t1Results.taskPeakDA_std.toString() },
            ":timeInfo": { M: mapToDynamo(t1Results.timeInfo) },
            ":resultsTable": { M: mapToDynamo(t1ResultsTable.t1ResultsTableData) }
        };

        updateExpression.push("sessionId = :sessionId");
        updateExpression.push("userId = :userId");
        updateExpression.push("sessionName = :sessionName");
        updateExpression.push("#ts = :timestamp");
        updateExpression.push("fileName = :fileName");
        updateExpression.push("s3Key = :s3Key");
        updateExpression.push("peakAccuracy = :peakAccuracy");
        updateExpression.push("errorMargin = :errorMargin");
        updateExpression.push("timeInfo = :timeInfo");
        updateExpression.push("resultsTable = :resultsTable");

        // Add parameter attributes
        Object.keys(params).forEach((key, index) => {
            const attrName = `:param${index}`;
            expressionAttributeValues[attrName] = params[key];
            updateExpression.push(`${key} = ${attrName}`);
        });

        console.log(JSON.stringify({
            level: 'INFO',
            message: 'Writing to DynamoDB',
            classifierId,
            tableName: process.env.CLASSIFIER_TABLE,
            updateExpression: updateExpression.join(", "),
            hasResultsTable: !!t1ResultsTable?.t1ResultsTableData,
            hasTimeInfo: !!t1Results?.timeInfo
        }));

        await ddbClient.send(new UpdateItemCommand({
            TableName: process.env.CLASSIFIER_TABLE,
            Key: { classifierId: { N: classifierId.toString() } },
            UpdateExpression: `SET ${updateExpression.join(", ")}`,
            ExpressionAttributeNames: {
                "#ts": "timestamp"
            },
            ExpressionAttributeValues: expressionAttributeValues
        }));

        console.log(JSON.stringify({
            level: 'INFO',
            message: 'DynamoDB write successful - Classifier processed',
            sessionId,
            sessionName,
            userId,
            classifierId,
            fileName,
            tableName: process.env.CLASSIFIER_TABLE
        }));
    } catch (error) {
        console.error(JSON.stringify({
            level: 'ERROR',
            message: 'Classifier processing failed',
            sessionId: sessionId || 'unknown',
            sessionName: sessionName || 'unknown',
            userId: userId || 'unknown',
            key: classifierKey,
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
                filters_used: {
                    L: p.CSP.filters_used.map(arr => {
                        if (!Array.isArray(arr) || arr.length === 0) {
                            return { L: [] };
                        }
                        return {
                            L: arr.map(sub => ({
                                L: sub.map(n => ({ N: n.toString() }))
                            }))
                        };
                    })
                }
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
                out_usedFeatureIDs: {
                    L: p.MI.out_usedFeatureIDs.map(arr => ({
                        L: Array.isArray(arr) ? arr.map(n => ({ N: n.toString() })) : []
                    }))
                }
            }
        };
    }

    return result;
}

// Helper to convert JS objects to DynamoDB attribute values
function mapToDynamo(obj) {
    if (!obj || typeof obj !== 'object') {
        return {};
    }
    const result = {};
    console.log('Mapping to Dynamo:', obj);
    for (const [key, value] of Object.entries(obj)) {
        if (Array.isArray(value)) {
            result[key] = {
                L: value.map(item => {
                    if (typeof item === 'number') return { N: item.toString() };
                    if (typeof item === 'string') return { S: item };
                    return { NULL: true };
                })
            };
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

async function fetchT1ResultsTable(bucket, userId, sessionName) {
    const t1Key = `${userId}/${sessionName}/T1 [resultTable].json`;
    return await fetchT1ResultsTableFromKey(bucket, t1Key);
}

async function fetchT1ResultsTableFromKey(bucket, t1Key) {
    try {
        const { Body } = await s3Client.send(new GetObjectCommand({
            Bucket: bucket,
            Key: t1Key
        }));

        const jsonString = await streamToString(Body);
        const t1ResultsTableData = JSON.parse(jsonString).T1_result_table;

        if (t1ResultsTableData !== undefined) {
            console.log(JSON.stringify({
                level: 'INFO',
                message: 'T1 results table extracted',
                t1Key,
                t1ResultsTableData
            }));
            return { t1ResultsTableData };
        }

        console.log(JSON.stringify({
            level: 'Error',
            message: 'T1 result table missing required fields',
            t1Key
        }));
        throw new Error('T1 result table missing required fields');
    } catch (error) {
        console.log(JSON.stringify({
            level: 'WARN',
            message: 'T1 result table file not found or invalid',
            t1Key,
            error: error.message
        }));
        throw error;
    }
}


async function fetchT1Results(bucket, userId, sessionName) {
    const t1Key = `${userId}/${sessionName}/T1 [results].json`;
    return await fetchT1ResultsFromKey(bucket, t1Key);
}

async function fetchT1ResultsFromKey(bucket, t1Key) {
    try {
        const { Body } = await s3Client.send(new GetObjectCommand({
            Bucket: bucket,
            Key: t1Key
        }));

        const jsonString = await streamToString(Body);
        const t1Data = JSON.parse(jsonString);

        const taskPeakDA_mean = t1Data.T1_results.orig.DA.smooth.taskPeakDA_mean;
        const taskPeakDA_std = t1Data.T1_results.orig.DA.smooth.taskPeakDA_std;
        const timeInfo = t1Data.T1_results.orig.timeInfo;

        if (taskPeakDA_mean !== undefined && taskPeakDA_std !== undefined && timeInfo !== undefined) {
            console.log(JSON.stringify({
                level: 'INFO',
                message: 'T1 results extracted',
                t1Key,
                taskPeakDA_mean,
                taskPeakDA_std
            }));
            return { taskPeakDA_mean, taskPeakDA_std, timeInfo };
        }

        console.log(JSON.stringify({
            level: 'Error',
            message: 'T1 results missing required fields',
            t1Key
        }));
        throw new Error('T1 results missing required fields');
    } catch (error) {
        console.log(JSON.stringify({
            level: 'WARN',
            message: 'T1 results file not found or invalid',
            t1Key,
            error: error.message
        }));
        throw error;
    }
}