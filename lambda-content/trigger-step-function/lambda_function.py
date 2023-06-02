import json
import boto3
import pprint

client = boto3.client('stepfunctions')


def lambda_handler(event, context):

    input = {
        "A": 1,
        "B": 2
    }

    pprint.pprint(event)
    response = client.start_execution(
        stateMachineArn='arn:aws:states:ap-southeast-2:459103101106:stateMachine:dpp_state_machine',
        input=json.dumps(event)
    )
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
