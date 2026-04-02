import json
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('your-table-name')  # Replace with actual table name

def lambda_handler(event, context):
    # Example: Get an item from DynamoDB
    response = table.get_item(Key={'id': 'example-id'})
    item = response.get('Item')
    
    return {
        'statusCode': 200,
        'body': json.dumps(item, default=str)  # Handle Decimal serialization
    }