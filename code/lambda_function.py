from __future__ import print_function
from crhelper import CfnResource
import logging
import json

logger = logging.getLogger(__name__)
helper = CfnResource()

def parseData(event):
    # Extract ResourceProperties from data
    resourceProperties = event.get("ResourceProperties", {})
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
        helper.Data['Status'] = "SUCCESS"
        # helper.Data.update({"Status": "SUCCESS"})
    except Exception as e:
        helper.init_failure(e)

@helper.delete
def delete(event, context):
    logger.info("Got Delete")


def lambda_handler(event, context):
    try:
        # Extract Data from SNS Message
        records = event.get("Records", {})
        Sns = records[0].get("Sns", {})
        data = json.loads(Sns["Message"])
        helper(data, context)
    except Exception as e:
        helper.init_failure(e)