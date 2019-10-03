import json
import boto3
import os
import time
import pprint
import copy

pp = pprint.PrettyPrinter(indent=4)


def lambda_handler(event, context):

    account_ids = get_accounts()

    image_ids = get_to_be_shared_amis(account_ids)
    print(image_ids)
    copied_image_ids = []
    local_image_ids = []
    for image_id in image_ids:
        local_image_id = copy_ami(image_id)
        copied_image_ids.append({"image_id": local_image_id, "account_id": image_id['account_id']})
        local_image_ids.append(local_image_id)

    print(copied_image_ids)
    if local_image_ids:
        add_tag_image(local_image_ids)

def get_accounts():
    client = boto3.client('organizations')
    accounts = set()
    response = client.list_accounts()
    for account in response['Accounts']:
        accounts.add( account['Id'] );
    next_token = response['NextToken']

    while 'NextToken' in response and response['NextToken'] is not None and response['NextToken'] != '':
        response = client.list_accounts(NextToken=str(response['NextToken']))
        for account in response['Accounts']:
            accounts.add( account['Id'] );
        if 'NextToken' not in response:
            break
            next_token = response['NextToken']

    current_account_id = boto3.client('sts').get_caller_identity().get('Account')
    accounts.remove(current_account_id)
    return accounts

def copy_ami(image_id):
    client = boto3.client('ec2')
    region = os.environ.get('AWS_REGION')
    response = client.copy_image(
                    Name=image_id['image_name'],
                    SourceImageId=image_id['image_id'],
                    SourceRegion=region,
                )
    print(response)
    return response['ImageId']

def get_to_be_shared_amis(account_ids):
    client = boto3.client('ec2')
    image_ids = []
    for account_id in account_ids:
        account_response = client.describe_images(Owners=[account_id])
        if account_response['Images'] != []:
            images = account_response['Images']
            for image in images:
                response = client.describe_images(
                    Filters=[
                        {
                            'Name': 'name',
                            'Values': [
                                image['Name'],
                            ]
                        },
                    ],
                    Owners=['self'])
                if response['Images'] == []:
                    print("Sharing Image: {} from Account: {}".format(image['Name'], account_id))
                    image_ids.append({"image_name": image['Name'],"image_id": image['ImageId'], "account_id": account_id})

    return image_ids


def share_ami_with_account(account_ids, image_id, source_account_id):

    client = boto3.client('ec2')

    # Loop on all AccountIds
    for account_id in account_ids:
        if account_id == source_account_id:
            print("Skipping share_ami_with_account: {}, imageId: {}.".format(account_id, image_id))
            continue
        try:
            # API call for modify_image_attribute for image id with an account id to be shared
            response = client.modify_image_attribute(
                ImageId=image_id,
                LaunchPermission={
                    'Add': [
                        {
                            'UserId': account_id
                        },
                    ]
                }
            )
            print(response)
            print("account_id: {}, imageId: {}, response code: {} times.".format(account_id, image_id, response["ResponseMetadata"]["HTTPStatusCode"]))
        except Exception as e:
            print(e)

def create_volume_permission_with_account(account_ids, snapshot_ids, source_account_id):

    client = boto3.client('ec2')

    # Loop on all AccountIds
    for account_id in account_ids:
        if account_id == source_account_id:
            print("Skipping create_volume_permission_with_account: {}, snapshot_id: {}".format(account_id, snapshot_ids))
            continue
        for snapshot_id in snapshot_ids:
            try:
                # API call for modify_image_attribute for image id with an account id to be shared
                response = client.modify_snapshot_attribute(
                    Attribute='createVolumePermission',
                    SnapshotId=snapshot_id,
                    CreateVolumePermission={
                        'Add': [
                            {
                                'UserId': account_id
                            },
                        ]
                    },
                    OperationType='add'
                )
                print("account_id: {}, snapshot_id: {}, response code: {} times.".format(account_id, snapshot_id, response["ResponseMetadata"]["HTTPStatusCode"]))
            except Exception as e:
                print(e)

def add_tag_image(image_ids):
    client = boto3.client('ec2')
    response = client.create_tags(
        Resources=image_ids,
        Tags=[
            {
                'Key': 'SHARED',
                'Value': 'true'
            },
        ]
    )
    print("image_ids: {}, response code: {} times.".format(image_ids, response["ResponseMetadata"]["HTTPStatusCode"]))
