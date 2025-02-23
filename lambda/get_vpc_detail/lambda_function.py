import os
import json
import boto3

def returnErrorResponse(statusCode,errorCode,errorType,errorReason):
    return{
            'statusCode': statusCode,
            'headers': {'Content-Type': 'application/json', 
                        "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
                        "Access-Control-Allow-Methods": "*"},
            'body': json.dumps({"errorCode": errorCode, "errorType": errorType, "errorReason": errorReason})
        }

def returnEmptySuccessResponse():
    return{
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json', 
                        "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
                        "Access-Control-Allow-Methods": "*"},
            'body': json.dumps({})
        }

def returnSuccessResponse(vpc_detail):
    return{
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json', 
                        "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
                        "Access-Control-Allow-Methods": "*"},
            'body': json.dumps(vpc_detail)
        }

def checkOrderifExist(orderId):
    dynamodb_resource = boto3.resource('dynamodb')
    vpc_table = dynamodb_resource.Table(os.environ['dynamodb_order_table_name'])
    item = vpc_table.get_item( Key={"orderId": orderId})
    print(item)
    if item.get('Item') != None:
        return item.get('Item')
    return False

def fetchVpcDetail(orderId):
    dynamodb_resource = boto3.resource('dynamodb')
    vpc_table = dynamodb_resource.Table(os.environ['dynamodb_vpc_table_name'])
    item = vpc_table.get_item( Key={"orderId": orderId})
    print(item)
    if item.get('Item') != None:
        return item.get('Item')
    return False

def lambda_handler(event, context):
    print(event)
    orderId = event.get('pathParameters',{}).get("vpcOrderId",{})
    if orderId == {}:
        return returnErrorResponse(400,400, "MissingParameter",  "orderId is missing in path parameter.")
    # check orderId is present in dynamoDB table
    vpc_order_data = checkOrderifExist(orderId)
    
    if vpc_order_data:
        vpc_detail = fetchVpcDetail(orderId)
        if vpc_detail:
            print(vpc_detail)
            return returnSuccessResponse(vpc_detail)
        else:
            return returnEmptySuccessResponse()
    else:
        return returnErrorResponse(400,400, "InvalidParameterValue",  "An invalid or out-of-range value was supplied for the input parameter vpcOrderId")



