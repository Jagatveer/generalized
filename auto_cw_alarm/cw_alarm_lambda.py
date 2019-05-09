import boto3
import json
import logging
import os
# Create connections
client = boto3.client('ec2')
ec2session = boto3.resource('ec2')
cw = boto3.client('cloudwatch')

#logger
LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

# Retrieves instance id from CloudWatch event
def get_instance_id(event):
    try:
        return event['detail']['EC2InstanceId']
    except KeyError as err:
        LOGGER.error(err)
        return False

        
def get_inststat(event):
    try:
        return event['detail-type']
    except KeyError as err:
        LOGGER.error(err)
        return False


def lambda_handler(event, context):

    session = boto3.session.Session()
    
    instanceid = get_instance_id(event)
    instancestat = get_inststat(event)

    SNS = os.environ['SNS_Topic']
    tag_name = os.environ['TagName']
    tag_value = os.environ['TagValue']
    tag_value2 = os.environ['TagValue2']
    mem_thr = int(os.environ['Mem_Thr_byte'])
    instancetype = client.describe_instances(InstanceIds=[instanceid])['Reservations'][0]['Instances'][0]['InstanceType']
 
    if instancestat == 'EC2 Instance Launch Successful':
        ec2instance = ec2session.Instance(instanceid)
        instancetag= ''
        for tags in ec2instance.tags:
                if tags["Key"] == tag_name:
                    instancetag = tags["Value"]
        if instancetag == tag_value:
# CPU alarm
            cw.put_metric_alarm(
            AlarmName='CPU Usage is high on %s  %s' % (instancetag, instanceid ),
            ComparisonOperator='GreaterThanThreshold',
            EvaluationPeriods=5,
            DatapointsToAlarm=3,
	        Unit='Percent',
            MetricName='CPUUtilization',
            
            Namespace='AWS/EC2',
            Period=60,
            Statistic='Average',
            Threshold=90.0,
            ActionsEnabled=True,
            AlarmActions=[

                SNS
        
            ],
            OKActions=[
                SNS
            ],
            AlarmDescription='CPU Usage is high on %s  %s' % (instancetag, instanceid ),
            Dimensions=[
                {
                'Name': 'InstanceId',
                'Value': instanceid
                },
            ],
           
        )

#status Check
            cw.put_metric_alarm(
            AlarmName='AWS Stauts Check Failed on %s  %s' % (instancetag, instanceid ),
            ComparisonOperator='GreaterThanThreshold',
            EvaluationPeriods=3,
            DatapointsToAlarm=2,
	        Unit='Count',
            MetricName='StatusCheckFailed_Instance',
            
            Namespace='AWS/EC2',
            Period=60,
            Statistic='Average',
            Threshold=0,
            ActionsEnabled=True,
            AlarmActions=[
                SNS
        
            ],
            OKActions=[
                SNS
            ],
            AlarmDescription='AWS Stauts Check Failed on %s  %s' % (instancetag, instanceid ),
            Dimensions=[
            {
                'Name': 'InstanceId',
                'Value': instanceid
                },
            ],
        ) 
# DISK
            cw.put_metric_alarm(
            AlarmName='Disk usage high on %s  %s' % (instancetag , instanceid ),
            ComparisonOperator='GreaterThanOrEqualToThreshold',
            EvaluationPeriods=5,
            DatapointsToAlarm=5,
            Unit='Percent',
            MetricName='disk_used_percent',
        #   
            Namespace='CWAgent',
            Period=60,
            Statistic='Average',
            Threshold=80.0,
            ActionsEnabled=True,
            AlarmActions=[

                SNS
      
            ],
            OKActions=[
                SNS
        ],
            AlarmDescription='Disk usage high on %s  %s' % (instancetag , instanceid ),
            Dimensions=[
                {
                'Name': 'InstanceId',
                'Value': instanceid
                },
                {
                'Name': 'InstanceType',
                'Value': instancetype
                },
            ],
           
        )
#MEMOERY
            cw.put_metric_alarm(
            AlarmName='Free Memory Low on %s  %s' % (instancetag, instanceid),
            ComparisonOperator='LessThanOrEqualToThreshold',
            EvaluationPeriods=5,
            DatapointsToAlarm=5,
   
            Unit='Bytes',
            MetricName='mem_available',
            Namespace='CWAgent',
            Period=60,
            Statistic='Average',
            Threshold=mem_thr,
            ActionsEnabled=True,
            AlarmActions=[

                SNS
      
            ],
            OKActions=[
                SNS
            ],
            AlarmDescription='Free Memory Low on %s  %s' % (instancetag, instanceid),
            Dimensions=[
                {
                'Name': 'InstanceId',
                'Value': instanceid
                },
                {
                'Name': 'InstanceType',
                'Value': instancetype   
                },
                  
                  
            ],
            
        )
        if instancetag == tag_value2:
# CPU alarm
            cw.put_metric_alarm(
            AlarmName='CPU Usage is high on %s  %s' % (instancetag, instanceid ),
            ComparisonOperator='GreaterThanThreshold',
            EvaluationPeriods=5,
            DatapointsToAlarm=3,
	        Unit='Percent',
            MetricName='CPUUtilization',
            
            Namespace='AWS/EC2',
            Period=60,
            Statistic='Average',
            Threshold=90.0,
            ActionsEnabled=True,
            AlarmActions=[

                SNS
        
            ],
            OKActions=[
                SNS
            ],
            AlarmDescription='CPU Usage is high on %s  %s' % (instancetag, instanceid ),
            Dimensions=[
                {
                'Name': 'InstanceId',
                'Value': instanceid
                },
            ],
           
        )

#status Check
            cw.put_metric_alarm(
            AlarmName='AWS Stauts Check Failed on %s  %s' % (instancetag, instanceid ),
            ComparisonOperator='GreaterThanThreshold',
            EvaluationPeriods=3,
            DatapointsToAlarm=2,
	        Unit='Count',
            MetricName='StatusCheckFailed_Instance',
            
            Namespace='AWS/EC2',
            Period=60,
            Statistic='Average',
            Threshold=0,
            ActionsEnabled=True,
            AlarmActions=[
                SNS
        
            ],
            OKActions=[
                SNS
            ],
            AlarmDescription='AWS Stauts Check Failed on %s  %s' % (instancetag, instanceid ),
            Dimensions=[
            {
                'Name': 'InstanceId',
                'Value': instanceid
                },
            ],
        ) 
