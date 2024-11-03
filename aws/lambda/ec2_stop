def stop_ec2_instances(event, context):
        ec2_client = boto3.client('ec2')

        # Describe instances with the tag 'autostop' set to 'yes'
        instances = ec2_client.describe_instances(
            Filters=[
                {
                    'Name': 'tag:autostop',
                    'Values': ['yes']
                }
            ]
        )

        for reservation in instances['Reservations']:
            for instance in reservation['Instances']:
                instance_id = instance['InstanceId']
                # Stop the EC2 instance
                response = ec2_client.stop_instances(
                    InstanceIds=[instance_id]
                )
                print(f'Stopped EC2 instance {instance_id}: {response}')

        return {
            'statusCode': 200,
            'body': 'EC2 instances stopped successfully'
        }