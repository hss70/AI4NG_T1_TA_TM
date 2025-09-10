const { S3Client, ListObjectsV2Command } = require('@aws-sdk/client-s3');
const { fromIni } = require('@aws-sdk/credential-providers');

const s3 = new S3Client({ 
    region: 'eu-west-2',
    credentials: fromIni({ profile: 'hardeepGmail' })
});

async function listAllObjects(bucketName) {
    const objects = [];
    let continuationToken;

    do {
        const params = {
            Bucket: bucketName,
            MaxKeys: 1000,
            ContinuationToken: continuationToken
        };

        const response = await s3.send(new ListObjectsV2Command(params));
        objects.push(...response.Contents);
        continuationToken = response.NextContinuationToken;

        console.log(`Retrieved ${objects.length} objects so far...`);
    } while (continuationToken);

    return objects;
}

// Usage: node list-s3-objects.js bucket-name
const bucketName = process.argv[2];
if (!bucketName) {
    console.error('Usage: node list-s3-objects.js <bucket-name>');
    process.exit(1);
}

listAllObjects(bucketName)
    .then(objects => {
        console.error(`Total objects: ${objects.length}`);
        
        // Find max path depth
        const maxDepth = Math.max(...objects.map(obj => obj.Key.split('/').length));
        
        // CSV header
        const headers = [];
        for (let i = 0; i < maxDepth; i++) {
            headers.push(`Level${i + 1}`);
        }
        headers.push('Size', 'LastModified');
        console.log(headers.join(','));
        
        // CSV rows
        objects.forEach(obj => {
            const pathParts = obj.Key.split('/');
            const row = [];
            
            // Add path components
            for (let i = 0; i < maxDepth; i++) {
                row.push(pathParts[i] || '');
            }
            
            // Add size and last modified
            row.push(obj.Size || 0);
            row.push(obj.LastModified ? obj.LastModified.toISOString() : '');
            
            console.log(row.join(','));
        });
    })
    .catch(console.error);