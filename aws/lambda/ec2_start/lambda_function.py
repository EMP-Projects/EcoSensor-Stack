def start_ec2_instances(event, context):
        ec2_client = boto3.client('ec2')

        # Describe instances with the tag 'autostart' set to 'yes'
        instances = ec2_client.describe_instances(
            Filters=[
                {
                    'Name': 'tag:autostart',
                    'Values': ['yes']
                }
            ]
        )

        for reservation in instances['Reservations']:
            for instance in reservation['Instances']:
                instance_id = instance['InstanceId']
                # Start the EC2 instance
                response = ec2_client.start_instances(
                    InstanceIds=[instance_id]
                )
                print(f'Started EC2 instance {instance_id}: {response}')

        return {
            'statusCode': 200,
            'body': 'EC2 instances started successfully'
        }
