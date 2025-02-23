data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#-----------------------------------------------------------
# CloudWatch Log group
#-----------------------------------------------------------
resource "aws_cloudwatch_log_group" "log_group" {
  name              = format("%s%s", "/api-gateway/", var.api_name)
  retention_in_days = 90

  tags = merge(
    var.common_tags,
    {
      Name        = format("%s%s", "/api-gateway/", var.api_name),
      environment = var.env
    }
  )
}


#-----------------------------------------------------------
# Cloudwatch IAM Role for API Gateway
#-----------------------------------------------------------
resource "aws_iam_role" "iam_role" {
  name                  = var.iam_role_name
  path                  = "/"
  force_detach_policies = true
  assume_role_policy    = data.aws_iam_policy_document.api_gateway_assume_policy.json
  tags = merge(
    var.common_tags,
    {
      Name        = var.iam_role_name,
      environment = var.env
    }
  )
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "policy_attachment" {
  name   = format("%s%s", var.iam_role_name, "-policy")
  role   = aws_iam_role.iam_role.id
  policy = var.iaminlinepolicy
}

data "aws_iam_policy_document" "api_gateway_assume_policy" {
  policy_id = "assumepolicy"
  statement {
    sid    = "First"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_api_gateway_account" "api_account_settings" {
  cloudwatch_role_arn = aws_iam_role.iam_role.arn
}

#-----------------------------------------------------------
# API Gateway Resources
#-----------------------------------------------------------

resource "aws_api_gateway_rest_api" "api_gateway" {
  body = templatefile("${path.module}/api-schema/vpc.yaml",var.template_variables)
  name = var.api_name
  endpoint_configuration {
    types = [var.endpoint_config]
  }
}

resource "aws_api_gateway_deployment" "rest_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_rest_api.api_gateway.body]))
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on  = [module.api_gateway_response]
}

resource "aws_api_gateway_stage" "rest_api_stage" {
  depends_on           = [aws_cloudwatch_log_group.log_group, aws_api_gateway_account.api_account_settings]
  deployment_id        = aws_api_gateway_deployment.rest_api_deployment.id
  rest_api_id          = aws_api_gateway_rest_api.api_gateway.id
  stage_name           = var.stage_name
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.log_group.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      principalId             = "$context.authorizer.principalId"
      }
    )
  }
}

resource "aws_api_gateway_method_settings" "gateway_settings" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.rest_api_stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}


resource "aws_lambda_permission" "lambda_permission" {
  count         = length(var.integration_lambda_name)
  statement_id  = "AllowExecutionFromAPIGateway-${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = var.integration_lambda_name[count.index]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*${var.integration_lambda_source_path[count.index]}"
}

module "api_gateway_response" {
  source                                                  = "../api-gateway-response"
  api_gateway_id                                          = aws_api_gateway_rest_api.api_gateway.id
  gw_response_parameters = {
    "gatewayresponse.header.Content-Type"                 = "'application/json'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'*'"
  }
}