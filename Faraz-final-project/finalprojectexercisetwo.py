import boto3
from botocore.exceptions import ClientError

def list_volumes():
    ec2_resource = boto3.resource('ec2', region_name='us-west-1')

    instances = ec2_resource.instances.filter(
        Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
    for instance in instances:
        print(instance.state, instance.id)
        for item in instance.volumes.all():
            print item.id
            snapshot = ec2_resource.create_snapshot(VolumeId=item.id, Description="Taking backup")
            client = boto3.client('ec2', region_name='us-west-1')
            waiter=client.get_waiter('snapshot_completed')
            waiter.wait(SnapshotIds=[snapshot.id])
            print("snapshot complete")
    ec2_client = boto3.client('ec2', region_name='us-west-1')
    instance_ids = []
    for instance in instances:
        instance_ids.append(instance.id)
        
    terminate = ec2_client.terminate_instances(InstanceIds=instance_ids)

    print(("Instances deleted", instance_ids))



            # snapshot = boto3.client('ec2', region_name='us-west-1')
            # waiter=snapshot.get_waiter('snapshot_completed')
            # waiter.wait(SnapshotIds=snapshot_ids)
            # print ("snapshot complete")


list_volumes()

