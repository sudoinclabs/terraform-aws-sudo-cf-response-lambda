from __future__ import print_function
import os
import json
import boto3
import logging

# pip install crhelper -t .
from crhelper import CfnResource

# Initialize
logger = logging.getLogger(__name__)
helper = CfnResource(json_logging=False, log_level='DEBUG', boto_level='CRITICAL')

try:    
    sns = boto3.client('sns')
    topic_arn = os.environ['SNS_TOPIC_ARN']
except Exception as e:
    helper.init_failure(e)

def lambda_handler(event, context):
    helper(event, context)

@helper.create
@helper.update
def create(event, context):
    logger.info("Got Create/Update")
    try:
        # resourceProperties = event.get("requestPayload", {}).get("ResourceProperties", {})
        resourceProperties = event.get("ResourceProperties", {})

        if not resourceProperties:
            raise Exception('No ResourceProperties Provided' + json.dumps(event))
        else:
            sns_response = sns.publish(
                TopicArn = topic_arn,
                Message = json.dumps(resourceProperties)
            )
            
    except Exception as e:
        helper.init_failure(e)
        # raise Exception(e)

@helper.delete
def no_op(_, __):
    logger.info("Got Delete")
    pass