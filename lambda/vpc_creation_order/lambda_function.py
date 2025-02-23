import json
import boto3
import uuid
import datetime
import os
from botocore.exceptions import ClientError
from netaddr import IPNetwork

dynamodb_client = boto3.client('dynamodb')
stepfunctions = boto3.client('stepfunctions')

def returnErrorResponse(statusCode,errorCode,errorType,errorReason):
    return{
            'statusCode': statusCode,
            'headers': {'Content-Type': 'application/json', 
                        "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
                        "Access-Control-Allow-Methods": "*"},
            'body': json.dumps({"errorCode": errorCode, "errorType": errorType, "errorReason": errorReason})
        }

def returnSuccessResponse(orderId):
    return{
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json', 
                        "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
                        "Access-Control-Allow-Methods": "*"},
            'body': json.dumps({"orderId": orderId})
        }

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
    return None

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
    return None

  for zone in aws_zones:
    if zone['State'] == 'available':
      zones.append(zone['ZoneName'])

  return zones

def updateStatusInDynamoDB(orderId, regionName, cidr_block):
    try:
        dynamodb_client.put_item(
            TableName=os.environ['dynamodb_vpc_table_name'],
            Item={
                'orderId': {'S': orderId},
                'regionName': {'S': regionName},
                'cidr': {'S': cidr_block},
                'vpcOrderCreationDate': {'S': datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")},
            }
        )
    except Exception as e:
        raise Exception(f"Error in storing in DynamoDB table: {e}")
        
def lambda_handler(event, context):
    try:
        request_body = json.loads(event['body'])
        ec2 = boto3.client('ec2', region_name=request_body['region_name'])

        # Grab the available zones
        zones = get_zones(ec2)
        print(zones)
        if zones == None or len(zones) < 2:
            return returnErrorResponse(400,400, "Insufficent AZ",  "Sufficient Zones are not avaiable under provided region.")

        # Calculate the subnet sizes
        subnets = subnet_sizes(request_body['cidr_block'])
        if subnets == None:
            return returnErrorResponse(400,400, "Netmask not allowed",  "Netmask not allowed for Given CIDR.")
        orderId=str(uuid.uuid4())
        updateStatusInDynamoDB(orderId, request_body['region_name'], request_body['cidr_block'])

        #trigger step function for vopc creation flow
        stfData = {
          "region_name": request_body['region_name'],
          "cidr_block": request_body['cidr_block'],
          "orderId": orderId,
          "vpc_name": request_body['vpc_name'],

        }
        sfn_response = stepfunctions.start_execution(
            stateMachineArn=os.environ['sfn_vpc_creation'],
            name=orderId,
            input=json.dumps(stfData)
        ) 
        return returnSuccessResponse(orderId)
    except Exception as e:
        return returnErrorResponse(500, 500, "InternalFailure", "The request processing has failed because of an unknown error, exception or failure.")
                        