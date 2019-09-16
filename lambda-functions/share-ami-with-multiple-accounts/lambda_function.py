import json
import boto3

client = boto3.client('ec2')

def lambda_handler(event, context):
    client = boto3.client('ec2')

    # Account ids is a list of Accounts to which AMI need to be shared.
    accountids = ['accountid']

    # Image Id is AMI Id of an Image.
    imageid = 'amiid'
    
    # Loop on all AccountIds 
    for accountid in accountids:
        try:
            # API call for modify_image_attribute for image id with an account id to be shared
            response = client.modify_image_attribute(
                ImageId=imageid,
                LaunchPermission={
                    'Add': [
                        {
                            'UserId': accountid
                        },
                    ]
                }
            )
            print("accountid: {}, imageId: {}, response code: {} times.".format(accountid, imageid, response["ResponseMetadata"]["HTTPStatusCode"]))
        except Exception as e:
            print(e)