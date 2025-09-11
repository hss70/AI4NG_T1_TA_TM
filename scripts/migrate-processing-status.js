const { DynamoDBClient, BatchWriteItemCommand } = require('@aws-sdk/client-dynamodb');
const { fromIni } = require('@aws-sdk/credential-providers');
const fs = require('fs');
const csv = require('csv-parser');

const dynamodb = new DynamoDBClient({
    region: 'eu-west-2',
    credentials: fromIni({ profile: 'hardeepGmail' })
});
const TABLE_NAME = 'EEGProcessingStatusV2';

function generateSessionId(userId, sessionName) {
    const combined = userId + sessionName;
    let hash = 0;
    for (let i = 0; i < combined.length; i++) {
        const char = combined.charCodeAt(i);
        hash = ((hash << 5) - hash) + char;
        hash = hash & hash;
    }
    return Math.abs(hash);
}

async function migrateData(csvFilePath, s3CsvPath) {
    // Read S3 uploads and find latest for each user/session
    const latestUploads = {};
    await new Promise((resolve, reject) => {
        fs.createReadStream(s3CsvPath)
            .pipe(csv())
            .on('data', (row) => {
                // Skip empty rows
                if (!row.Level1 && !row.Level2 && !row.Level3) return;

                console.log('DEBUG row keys:', Object.keys(row));
                console.log('DEBUG Level1 value:', JSON.stringify(row.Level1));
                console.log('DEBUG Level1 value:', JSON.stringify(row[Object.keys(row)[0]]));

                const userId = row[Object.keys(row)[0]];
                const sessionName = row.Level2;
                const fileName = row.Level3;
                const lastModified = new Date(row.LastModified);

                console.log(`S3 Row: ${userId}/${sessionName}/${fileName} - ${lastModified}`);

                if (userId && sessionName && fileName && fileName.endsWith('.zip')) {
                    const key = `${userId}|${sessionName}`;
                    const fullPath = `${userId}/${sessionName}/${fileName}`;

                    if (!latestUploads[key] || lastModified > latestUploads[key].lastModified) {
                        latestUploads[key] = { fullPath, lastModified };
                        console.log(`Added upload: ${key} -> ${fullPath}`);
                    }
                } else {
                    console.log(`Skipped: missing data or not .zip`);
                }
            })
            .on('end', resolve)
            .on('error', reject);
    });

    const items = [];

    return new Promise((resolve, reject) => {
        fs.createReadStream(csvFilePath)
            .pipe(csv())
            .on('data', (row) => {
                const sessionId = generateSessionId(row.userId, row.sessionName);
                const uploadKey = `${row.userId}|${row.sessionName}`;
                const upload = latestUploads[uploadKey];

                console.log(`Status Row: ${row.userId}/${row.sessionName} -> Upload found: ${!!upload}`);
                if (upload) {
                    console.log(`  Upload path: ${upload.fullPath}`);
                }

                const item = {
                    sessionId: { N: sessionId.toString() },
                    sessionName: { S: row.sessionName },
                    userId: { S: row.userId },
                    status: { S: row.status }
                };

                // Add upload path from S3 data
                if (upload) {
                    item.uploadPath = { S: upload.fullPath };
                    console.log(`  Added uploadPath to item: ${upload.fullPath}`);
                }

                // Add optional fields if they exist
                if (row.startTime) item.startTime = { S: row.startTime };
                if (row.endTime) item.endTime = { S: row.endTime };
                if (row.processingDuration) item.processingDuration = { N: row.processingDuration };
                if (row.resultsPath) item.resultsPath = { S: row.resultsPath };
                if (row.exitCode) item.exitCode = { N: row.exitCode };
                if (row.error) item.error = { S: row.error };

                items.push(item);
            })
            .on('end', async () => {
                console.log(`Migrating ${items.length} items...`);

                // Batch write in chunks of 25 (DynamoDB limit)
                for (let i = 0; i < items.length; i += 25) {
                    const batch = items.slice(i, i + 25);
                    const params = {
                        RequestItems: {
                            [TABLE_NAME]: batch.map(item => ({ PutRequest: { Item: item } }))
                        }
                    };

                    try {
                        await dynamodb.send(new BatchWriteItemCommand(params));
                        console.log(`Migrated batch ${Math.floor(i / 25) + 1}`);
                    } catch (error) {
                        console.error(`Error migrating batch ${Math.floor(i / 25) + 1}:`, error);
                    }
                }

                resolve();
            })
            .on('error', reject);
    });
}

// Usage: node migrate-processing-status.js status.csv s3-objects.csv
const csvFile = process.argv[2];
const s3CsvFile = process.argv[3];
if (!csvFile || !s3CsvFile) {
    console.error('Usage: node migrate-processing-status.js <status-csv> <s3-objects-csv>');
    process.exit(1);
}

migrateData(csvFile, s3CsvFile)
    .then(() => console.log('Migration complete'))
    .catch(console.error);