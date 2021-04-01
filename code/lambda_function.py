from __future__ import print_function
from crhelper import CfnResource
import logging
import os
import json
import boto3

logger = logging.getLogger(__name__)
# Initialise the helper, all inputs are optional, this example shows the defaults
helper = CfnResource(json_logging=False, log_level='DEBUG', boto_level='CRITICAL', sleep_on_delete=120, ssl_verify=True)

try:
    sns = boto3.client('sns')
    topic_arn = os.environ['SNS_TOPIC_ARN']
except Exception as e:
    helper.init_failure(e)


@helper.create
@helper.update
def create(event, context):
    logger.info("Got Create")
    try:
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
    
    # parse the 
    # helper.Data.update({"test": "testdata"})

    # # To return an error to cloudformation you raise an exception:
    # if not helper.Data.get("test"):
    #     raise ValueError("this error will show in the cloudformation events log and console.")
    
    # return "MyResourceId"

@helper.delete
def delete(event, context):
    logger.info("Got Delete")
    # Delete never returns anything. Should not fail if the underlying resources are already deleted.
    # Desired state.


def lambda_handler(event, context):
    records = event.get("Records", {})
    Sns = records[0].get("Sns", {})
    data = json.loads(Sns["Message"])
    
    # return data
    # helper not working for SNS backed lambda invocation
    helper(data, context)