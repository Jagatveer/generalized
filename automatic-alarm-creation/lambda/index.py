import json
import pprint
import boto3
import os
from random import randint

def lambda_handler(event, context):
    # TODO implement
    print(event)
    if "eventName" in event["detail"] and event["detail"]["eventName"] == "CreateAutoScalingGroup":
        event_name=event["detail"]["requestParameters"]["autoScalingGroupName"]
        create_stack('ASG-CloudWatchEventStack' + str(randint(100000, 999999)), os.environ['ASGTemplate'], event_name)
    if "eventName" in event["detail"] and event["detail"]["eventName"] == "CreateLoadBalancer":
        event_name=event["detail"]["requestParameters"]["loadBalancerName"]
        create_stack('LB-CloudWatchEventStack' + str(randint(100000, 999999)), os.environ['LBTemplate'], event_name)
    if "state" in event["detail"]  and event["detail"]["state"] == "running" and event["detail-type"] == "EC2 Instance State-change Notification":
        event_name=event["detail"]["instance-id"]
        create_stack('EC2-CloudWatchEventStack' + str(randint(100000, 999999)), os.environ['EC2Template'], event_name)
    if "eventName" in event["detail"] and event["detail"]["eventName"] == "CreateDBInstance":
        event_name=event["detail"]["requestParameters"]["dBInstanceIdentifier"]
        create_stack('RDS-CloudWatchEventStack' + str(randint(100000, 999999)), os.environ['RDSTemplate'], event_name)

def create_stack(stack_name, template_url, event_name):
    try:
        client = boto3.client('cloudformation')
        response = client.create_stack(
            StackName=stack_name,
            TemplateURL=template_url,
            Parameters=[
                {
                    'ParameterKey': 'ParameterResourceType',
                    'ParameterValue': event_name
                },
                {
                    'ParameterKey': 'StackAlarmTopic',
                    'ParameterValue': os.environ['SNSTopic']
                }
            ]
        )    
        pprint.pprint(response)
    except Exception as e:
        print(e)