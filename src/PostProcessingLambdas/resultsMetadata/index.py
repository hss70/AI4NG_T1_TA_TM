import os
import time
import boto3
from urllib.parse import unquote_plus

dynamodb = boto3.resource('dynamodb')
status_table = dynamodb.Table(os.environ['STATUS_TABLE'])
s3 = boto3.client('s3')

def handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = unquote_plus(record['s3']['object']['key'])
        
        # Skip directory markers
        if key.endswith('/'):
            continue
            
        try:
            # Extract path components (format: user/session/results/file.ext)
            path_parts = key.split('/')
            if len(path_parts) < 4:
                continue
                
            user_id = path_parts[0]
            session_id = path_parts[1]
            file_name = path_parts[-1]
            
            # Get file metadata
            head = s3.head_object(Bucket=bucket, Key=key)
            file_type = file_name.split('.')[-1].upper() if '.' in file_name else 'UNKNOWN'
            
            # Update status table
            status_table.update_item(
                Key={'sessionId': session_id},
                UpdateExpression="ADD files :file SET lastUpdated = :now",
                ExpressionAttributeValues={
                    ':file': {'SS': [key]},
                    ':now': {'N': str(int(time.time()))}
                }
            )
            
            print(f"Recorded metadata for: {key}")
        
        except Exception as e:
            print(f"Error processing {key}: {str(e)}")