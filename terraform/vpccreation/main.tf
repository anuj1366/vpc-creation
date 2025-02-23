data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#-----------------------------------------------------------
# Create DynamoDB Table
#-----------------------------------------------------------

module "dynamodb_store_vpc_data" {
  source                  = "../modules/dynamodb"
  dynamodb_name           = "dynamodb-vpc-data"
  billing_mode            = "PAY_PER_REQUEST"
  hash_key                = "orderId"
  attributes = {
    name = "orderId"
    type = "S"
  }
  server_side_encryption = true
  common_tags            = var.common_tags
  env                    = var.ENV
}

module "dynamodb_store_vpc_order" {
  source                  = "../modules/dynamodb"
  dynamodb_name           = "dynamodb-vpc-order"
  billing_mode            = "PAY_PER_REQUEST"
  hash_key                = "orderId"
  attributes = {
    name = "orderId"
    type = "S"
  }
  server_side_encryption = true
  common_tags            = var.common_tags
  env                    = var.ENV
}

# #--------------------------------------------------------------------
# # AWS Lambda
# #---------------------------------------------------------------------

module "lambda_post_create_vpc" {
  source               = "../modules/lambda"
  lambda_function_name = "create_vpc"
  lambda_description   = "This lambda responds to POST /vpc API call and will create vpc resources"
  lambda_env_variables = { 
                          "dynamodb_vpc_table_name" = module.dynamodb_store_vpc_data.id
                          }
  iam_role_name        = "Lambda_Role_Create_VPC"
  iaminlinepolicy      = data.aws_iam_policy_document.iam-policy-lambda-createvpc.json
  env                  = var.ENV
  common_tags          = var.common_tags
}

module "lambda_get_vpc" {
  source               = "../modules/lambda"
  lambda_function_name = "get_vpc_detail"
  lambda_description   = "This lambda responds to GET /vpc API call and will return vpc details"
  lambda_env_variables = { 
                          "dynamodb_vpc_table_name" = module.dynamodb_store_vpc_data.id,
                          "dynamodb_order_table_name" = module.dynamodb_store_vpc_order.id,
                          }
  iam_role_name        = "Lambda_Role_Get_VPC"
  iaminlinepolicy      = data.aws_iam_policy_document.iam-policy-lambda-get-vpc.json
  priority             = "P1"
  env                  = var.ENV
  common_tags          = var.common_tags
}

module "lambda_handle_vpc_request" {
  source               = "../modules/lambda"
  lambda_function_name = "vpc_creation_order"
  lambda_description   = "This lambda responds to POST /vpc API call and will create vpc creation orderId"
  lambda_env_variables = { 
                          "dynamodb_vpc_table_name" = module.dynamodb_store_vpc_order.id
                          "sfn_vpc_creation" = module.step_function_vpc_creation.step_func_arn
                          }
  iam_role_name        = "Lambda_Role_vpc_creation_order"
  iaminlinepolicy      = data.aws_iam_policy_document.iam-policy-lambda-createvpcorder.json
  env                  = var.ENV
  common_tags          = var.common_tags
}




#--------------------------------------------------------------------
# API Gateway
#---------------------------------------------------------------------

module "api_gateway" {
  source                                    = "../modules/api-gateway"
  api_name                                  = "create-vpc-product-api"
  iam_role_name                             = "API_GW_Role_CW_Logs"
  iaminlinepolicy                           = data.aws_iam_policy_document.iam-policy-api-gateway-logs.json
  endpoint_config                           = "REGIONAL"
  stage_name                                = var.ENV
  integration_lambda_name                   = ["get_vpc_detail", "vpc_creation_order"]
  integration_lambda_source_path            = ["/GET/vpc/", "/POST/vpc"]
  env                                       = var.ENV
  common_tags                               = var.common_tags
  template_variables                        = { "region" = data.aws_region.current.name, 
                                                "create_vpc_order_arn" = module.lambda_handle_vpc_request.lambda_arn
                                                "get_vpc_lambda_arn" = module.lambda_get_vpc.lambda_arn
                                                "cognito_userpool_arn" = module.APIGatewayUserpool.arn 
                                                }                                    
}

#--------------------------------------------------------------------
# STEP FUNCTION
#---------------------------------------------------------------------
module "step_function_vpc_creation" {
  source         = "../modules/step_function"
  step_func_name = "vpc_creation_step_function"
  definition = templatefile("../step_func_definitions/vpc_creation.json", {
    create_vpc_lambda          = module.lambda_post_create_vpc.lambda_arn 
  })
  common_tags     = var.common_tags
  env             = var.ENV
  iam_role_name   = "Stepfn_Role_VPC_Creation"
  iaminlinepolicy = data.aws_iam_policy_document.iam-policy-vpc-creation-Stepfn.json
  priority        = "P1"
}


#-----------------------------------------------------------
#Cognito Setup
#-----------------------------------------------------------

module "APIGatewayUserpool" {
  source         = "../modules/cognito"
  user_pool_name = "APIGatewayUserpool"
  password_policy_minimum_length                   = 32
  password_policy_require_lowercase                = true
  password_policy_require_numbers                  = true
  password_policy_require_symbols                  = true
  password_policy_require_uppercase                = true
  password_policy_temporary_password_validity_days = 7

  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]
  deletion_protection      = "ACTIVE"

  domain_name                 = "createdemovpc"
  user_pool_mfa_configuration = "OFF"

  device_configuration_challenge_required_on_new_device      = true
  device_configuration_device_only_remembered_on_user_prompt = true
  common_tags                                = var.common_tags
  env                                        = var.ENV
}


#-----------------------------------------------------------
#Userpool client
#-----------------------------------------------------------
module "UserPoolClient_APIGatewayUser" {
  source                       = "../modules/cognito/userpoolclient"
  client_name                  = "APIGatewayUser"
  refresh_token_validity       = 30
  supported_identity_providers = ["COGNITO"]
  callback_urls                = ["https://example.com/index.html"]
  allowed_oauth_flows          = ["code","implicit"]
  allowed_oauth_scopes         = ["aws.cognito.signin.user.admin", "email", "openid", "phone", "profile"]
  explicit_auth_flows          = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
  user_pool_id                 = module.APIGatewayUserpool.id

}





