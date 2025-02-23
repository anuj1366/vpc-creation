import json
import boto3
import datetime
import os
from botocore.exceptions import ClientError
from netaddr import IPNetwork

subnetDetail =[]
dynamodb_client = boto3.client('dynamodb')



def returnErrorResponse(statusCode,errorCode,errorType,errorReason):
    return{
            'statusCode': statusCode,
            'headers': {'Content-Type': 'application/json', 
                        "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
                        "Access-Control-Allow-Methods": "*"},
            'body': json.dumps({"errorCode": errorCode, "errorType": errorType, "errorReason": errorReason})
        }


def create_sub(ec2, vpc_id, subnets, zones, name):
  """
  Create subnets
  """

  i = 0
  subnet_ids = []
  tier = 'public'

  for subnet in subnets:

    # Create a subnet

    args = {
      'AvailabilityZone' : zones[i],
      'CidrBlock' : str(subnet),
      'VpcId' : vpc_id
    }

    try:
      sub = ec2.create_subnet(**args)['Subnet']
    except ClientError as e:
      print(e.response['Error']['Message'])
      raise Exception

    subnet_id = sub['SubnetId']
    subnet_ids.append(subnet_id)

    # Tag the resource

    tag = Tag(name, 'sub' + '-' + tier); tag.resource(ec2, subnet_id)
    print('sub_id: {} size: {} zone: {} tier: {}'.format(subnet_id, subnet, zones[i], tier))

    subnetObj = {
      "subnetSize": str(subnet),
      "subnetId": subnet_id,
      "subnetZone": zones[i],
      "subnetTier": tier
    }
    subnetDetail.append(subnetObj)

    i += 1

    if i == 2:
      i = 0
      tier = 'private'

  return subnet_ids

class Tag():

  def __init__(self, name, resource):

    self.name = name.lower() + '-' + resource

  def resource(self, ec2, resource_id):

    try:
      result = ec2.create_tags(
        Resources = [
          resource_id 
        ],
        Tags = [
          {
            'Key': 'Name',
            'Value': self.name
          }
        ]
      )
    except ClientError as e:
      print(e.response['Error']['Message'])
      raise Exception

def create_vpc(ec2, cidr, name):
  """
  Create a VPC
  """

  # Create the VPC

  args = {
    'CidrBlock' : cidr,
    'InstanceTenancy' : 'default'
  }

  try:
    vpc = ec2.create_vpc(**args)['Vpc']
  except ClientError as e:
    print(e.response['Error']['Message'])
    raise Exception

  vpc_id = vpc['VpcId']

  # Add DNS support
  # modify_vpc_attribute() only updates one attribute at a time

  try:
    result = ec2.modify_vpc_attribute(
      EnableDnsSupport = {
          'Value': True
      },
      VpcId = vpc_id
    )

    result = ec2.modify_vpc_attribute(
      EnableDnsHostnames = {
        'Value': True
      },
      VpcId = vpc_id
    )
  except ClientError as e:
    print(e.response['Error']['Message'])
    raise Exception

  # Tag the resource

  tag = Tag(name, 'vpc'); tag.resource(ec2, vpc_id)
  print('vpc_id: {}'.format(vpc_id))

  return vpc_id

def subnet_sizes(cidr):
  """
  Calculate subnets sizes
  """

  # Permitted netmasks

  netmasks = (
    '255.255.255.0',
    '255.255.254.0',
    '255.255.252.0',
    '255.255.248.0',
    '255.255.240.0',
    '255.255.224.0',
    '255.255.192.0',
    '255.255.128.0',
    '255.255.0.0'
  )

  ip = IPNetwork(cidr)
  mask = ip.netmask

  if str(mask) not in netmasks:
    print('Netmask not allowed: {}'.format(mask))
    raise Exception

  # Create 4 equal size subnet blocks with the available CIDR space

  for n, netmask in enumerate(netmasks):
    if str(mask) == netmask:
      subnets = list(ip.subnet(26 - n))

  return subnets

def get_zones(ec2):
  """
  Return all available zones in the region
  """

  zones = []

  try:
    aws_zones = ec2.describe_availability_zones()['AvailabilityZones']
  except ClientError as e:
    print(e.response['Error']['Message'])
    raise Exception

  for zone in aws_zones:
    if zone['State'] == 'available':
      zones.append(zone['ZoneName'])

  return zones

def storeDataInDynamoDB(vpcId, subnetDetail, orderId, vpcName, regionName, cidrBlock):
    try:
        dynamodb_client.put_item(
            TableName=os.environ['dynamodb_vpc_table_name'],
            Item={
                'orderId': {'S': orderId},
                'cidrBlock': {'S': cidrBlock},
                'vpcId':{'S': vpcId},
                'vpcName':{'S': vpcName},
                'regionName': {'S': regionName},
                'subnetDetail': subnetDetail,
                'vpcOrderCreationDate': {'S': datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")},
            }
        )
    except Exception as e:
        raise Exception(f"Error in storing in DynamoDB table: {e}")
    
def lambda_handler(event, context):
  try:
    invokingEvent = event['input']
    ec2 = boto3.client('ec2', region_name=invokingEvent['region_name'])
    zones = get_zones(ec2)
    subnets = subnet_sizes(invokingEvent['cidr_block'])
    vpcName = invokingEvent.get('vpc_name','test')
    vpc_id = create_vpc(ec2, invokingEvent['cidr_block'], vpcName)
    create_sub(ec2, vpc_id, subnets, zones, vpcName)
    print(subnetDetail)

    # Convert subnetDetail to a DynamoDB-compatible format
    subnetDetail_ddb = {
        'L': [
            {'M': {key: {'S': str(value)} for key, value in subnet.items()}}
            for subnet in subnetDetail
        ]
    }

    storeDataInDynamoDB(vpc_id, subnetDetail_ddb, invokingEvent['orderId'],vpcName,invokingEvent['region_name'],invokingEvent['cidr_block'])
  except Exception as e:
    print(e)
    raise Exception
