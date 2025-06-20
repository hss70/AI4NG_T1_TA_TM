import os
import json
import boto3
from urllib.parse import unquote_plus

dynamodb = boto3.resource('dynamodb')
classifier_table = dynamodb.Table(os.environ['CLASSIFIER_TABLE'])
s3 = boto3.client('s3')

def handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = unquote_plus(record['s3']['object']['key'])
        
        # Only process classifier JSON files
        if not key.endswith('.json'):
            continue
            
        try:
            # Get classifier JSON
            response = s3.get_object(Bucket=bucket, Key=key)
            classifier_data = json.loads(response['Body'].read().decode('utf-8'))
            
            # Extract session ID from path (format: user/session/results/file.json)
            path_parts = key.split('/')
            user_id = path_parts[0]
            session_id = path_parts[1]
            
            # Store in DynamoDB
            classifier_table.put_item(Item={
                'sessionId': session_id,
                'timestamp': int(time.time()),
                'userId': user_id,
                'classifierType': classifier_data.get('type', 'FBCSP'),
                'accuracy': classifier_data.get('accuracy', 0),
                'features': json.dumps(classifier_data.get('features', [])),
                'parameters': json.dumps(classifier_data.get('parameters', {}))
            })
            
            print(f"Processed classifier for session: {session_id}")
        
        except Exception as e:
            print(f"Error processing {key}: {str(e)}")