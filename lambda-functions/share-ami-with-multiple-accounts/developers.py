import json
import boto3
import os

import pprint
pp = pprint.PrettyPrinter(indent=4)


def lambda_handler(event, context):

    image_and_snap_ids = get_to_be_shared_amis()
    print(image_and_snap_ids)
    # Account ids is a list of Accounts to which AMI need to be shared.
    account_ids = [os.environ['MASTER_ACCOUNT']]

    image_ids = []
    # Image Id is AMI Id of an Image.
    for image_and_snap_id in image_and_snap_ids:
        #print(image_and_snap_id)
        share_ami_with_account(account_ids, image_and_snap_id['ImageId'])
        create_volume_permission_with_account(account_ids, image_and_snap_id['SnapshotIds'])
        image_ids.append(image_and_snap_id['ImageId'])
    if image_ids:
        add_tag_image(image_ids)

def get_to_be_shared_amis():
    client = boto3.client('ec2')
    response = client.describe_images(Owners=['self'])

    images = response['Images']
    image_and_snap_ids = []
    for image in images:
        if 'Tags' in image:
            share_needed = False
            already_shared = False
            for tag in image['Tags']:
                if tag['Key'].lower() == 'shared' and tag['Value'].lower() == 'true':
                    share_needed = True

                if tag['Key'].lower() == 'already_shared':
                     already_shared = True

            if share_needed and not already_shared:
                snapshot_ids = []
                block_devices = image['BlockDeviceMappings']

                for block_device in block_devices:
                    snapshot_ids.append(block_device['Ebs']['SnapshotId'])

                image_and_snap_ids.append(
                                            {
                                                'ImageId': image['ImageId'],
                                                'SnapshotIds': snapshot_ids
                                            }
                                         )
    return image_and_snap_ids


def share_ami_with_account(account_ids, image_id):

    client = boto3.client('ec2')

    # Loop on all AccountIds
    for account_id in account_ids:
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
            print("account_id: {}, imageId: {}, response code: {} times.".format(account_id, image_id, response["ResponseMetadata"]["HTTPStatusCode"]))
        except Exception as e:
            print(e)


def create_volume_permission_with_account(account_ids, snapshot_ids):

    client = boto3.client('ec2')

    # Loop on all AccountIds
    for account_id in account_ids:
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
                'Key': 'ALREADY_SHARED',
                'Value': ''
            },
        ]
    )
    print("image_ids: {}, response code: {} times.".format(image_ids, response["ResponseMetadata"]["HTTPStatusCode"]))
