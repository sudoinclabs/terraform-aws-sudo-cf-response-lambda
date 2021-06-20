# imports
from crhelper import CfnResource
import logging
import json

# initialization
logger = logging.getLogger(__name__)
helper = CfnResource()

def parseData(event):
    # extract ResourceProperties from data
    resourceProperties = event.get("ResourceProperties")
    if not resourceProperties:
        helper.init_failure('No ResourceProperties Provided')
    else:
        return resourceProperties

@helper.create       
@helper.update
def create(event, context):
    logger.info("Got Create/Update")
    try:
        resourceProperties = parseData(event)
        # return status to cloudformation
        helper.Data['Status'] = "SUCCESS"

    except Exception as e:
        helper.init_failure(e)

@helper.delete
def delete(event, context):
    logger.info("Got Delete")


def lambda_handler(event, context):
    try:
        # extract Message from SNS.
        Records = event.get("Records")
        Sns = Records[0].get("Sns")
        Message = json.loads(Sns["Message"])
        # invoke crhelper
        helper(Message, context)
    except Exception as e:
        helper.init_failure(e)