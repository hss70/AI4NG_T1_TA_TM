import os
import json
import boto3
from datetime import datetime
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['STATUS_TABLE'])

def handler(event, context):
    try:
        # Extract session ID from path parameters
        session_id = event['pathParameters']['sessionId']
        
        # Get status from DynamoDB
        response = table.get_item(Key={'sessionId': session_id})
        
        if 'Item' not in response:
            return {
                'statusCode': 404,
                'body': json.dumps({'error': 'Session not found'})
            }
        
        item = response['Item']
        
        # Prepare response
        status_info = {
            'sessionId': session_id,
            'status': item.get('status', 'UNKNOWN'),
            'userId': item.get('userId', ''),
            'startTime': int(item.get('startTime', 0)),
            'processingDuration': int(item.get('processingDuration', 0)),
            'resultsPath': item.get('resultsPath', ''),
            'exitCode': int(item.get('exitCode', -1))
        }
        
        # Add human-readable timestamp
        if 'startTime' in item:
            status_info['startTimeISO'] = datetime.utcfromtimestamp(
                int(item['startTime'])
            ).isoformat() + 'Z'
        
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps(status_info)
        }
    
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }