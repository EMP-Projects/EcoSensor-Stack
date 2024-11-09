import json
import boto3

def lambda_handler(event, context):
    ec2_client = boto3.client('ec2')

    # Extract filter value from the event
    ec2_instance_name = event.get('Name')

    print(f"EC2 Instance Name: {ec2_instance_name}")
    
    # Describe instances with the tag 'autostart' set to 'yes'
    instances = ec2_client.describe_instances(
        Filters=[
            {
                'Name': 'tag:autoip',
                'Values': ['yes']
            },
            {
                'Name': 'tag:Name',
                'Values': [ec2_instance_name]
            }
        ]
    )

    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            public_dns = instance.get('PublicDnsName')

    return {
        'statusCode': 200,
        'body': public_dns
    }