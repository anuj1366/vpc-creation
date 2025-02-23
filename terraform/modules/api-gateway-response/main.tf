# To decouple and trigger gateway response resources everytime, since redeployment of api gateway deployment(aws_api_gateway_deployment) overrites them.
resource "null_resource" "custom_trigger" {
 triggers = {
    always_run = "${timestamp()}"
  }
}

resource "aws_api_gateway_gateway_response" "resp_400" {
  rest_api_id   = var.api_gateway_id 
  status_code   = "400"
  response_type = "BAD_REQUEST_BODY"

  response_templates = {
    "application/json" = "{\"status\":400, \"errorType\": \"ValidationError\", \"errorReason\":\"The input fails to satisfy the constraints specified by the service.\"}"
  }
  response_parameters = var.gw_response_parameters
  lifecycle {
    create_before_destroy = false
    replace_triggered_by = [
      null_resource.custom_trigger
    ]
  }
}

resource "aws_api_gateway_gateway_response" "resp_401" {
  rest_api_id   = var.api_gateway_id 
  status_code   = "401"
  response_type = "UNAUTHORIZED"

  response_templates = {
    "application/json" = "{\"status\":401, \"errorType\": \"MissingAuthentication\", \"errorReason\":\"The request must contain a valid access token.\"}"
  }
  response_parameters = var.gw_response_parameters
  lifecycle {
    create_before_destroy = false
    replace_triggered_by = [
      null_resource.custom_trigger
    ]
  }
}

resource "aws_api_gateway_gateway_response" "resp_403" {
  rest_api_id   = var.api_gateway_id 
  status_code   = "403"
  response_type = "ACCESS_DENIED"

  response_templates = {
    "application/json" = "{\"status\":403, \"errorType\": \"NotAuthorized\", \"errorReason\":\"You do not have permission to perform this action.\"}"
  }
  response_parameters = var.gw_response_parameters
  lifecycle {
    create_before_destroy = false
    replace_triggered_by = [
      null_resource.custom_trigger
    ]
  }
}



resource "aws_api_gateway_gateway_response" "resp_404" {
  rest_api_id   = var.api_gateway_id 
  status_code   = "404"
  response_type = "RESOURCE_NOT_FOUND"

  response_templates = {
    "application/json" = "{\"status\":404, \"errorType\": \"MalformedQueryString\", \"errorReason\":\"The query string contains a syntax error.\"}"
  }
  response_parameters = var.gw_response_parameters
  lifecycle {
    create_before_destroy = false
    replace_triggered_by = [
      null_resource.custom_trigger
    ]
  }
}

resource "aws_api_gateway_gateway_response" "resp_429" {
  rest_api_id   = var.api_gateway_id 
  status_code   = "429"
  response_type = "THROTTLED"

  response_templates = {
    "application/json" = "{\"status\":429, \"errorType\": \"ThrottlingException\", \"errorReason\":\"The request was denied due to request throttling.\"}"
  }
  response_parameters = var.gw_response_parameters
  lifecycle {
    create_before_destroy = false
    replace_triggered_by = [
      null_resource.custom_trigger
    ]
  }
}

resource "aws_api_gateway_gateway_response" "resp1_500" {
  rest_api_id   = var.api_gateway_id 
  status_code   = "500"
  response_type = "AUTHORIZER_FAILURE"

  response_templates = {
    "application/json" = "{\"status\":500, \"errorType\": \"InternalFailure\", \"errorReason\":\"The request processing has failed because of an unknown error, exception or failure.\"}"
  }
  response_parameters = var.gw_response_parameters
  lifecycle {
    create_before_destroy = false
    replace_triggered_by = [
      null_resource.custom_trigger
    ]
  }
}

resource "aws_api_gateway_gateway_response" "resp2_500" {
  rest_api_id   = var.api_gateway_id 
  status_code   = "500"
  response_type = "API_CONFIGURATION_ERROR"

  response_templates = {
    "application/json" = "{\"status\":500, \"errorType\": \"InternalFailure\", \"errorReason\":\"The request processing has failed because of an unknown error, exception or failure.\"}"
  }
  response_parameters = var.gw_response_parameters
  lifecycle {
    create_before_destroy = false
    replace_triggered_by = [
      null_resource.custom_trigger
    ]
  }
}

resource "aws_api_gateway_gateway_response" "resp3_500" {
  rest_api_id   = var.api_gateway_id 
  status_code   = "500"
  response_type = "AUTHORIZER_CONFIGURATION_ERROR"

  response_templates = {
    "application/json" = "{\"status\":500, \"errorType\": \"InternalFailure\", \"errorReason\":\"The request processing has failed because of an unknown error, exception or failure.\"}"
  }
  response_parameters = var.gw_response_parameters
  lifecycle {
    create_before_destroy = false
    replace_triggered_by = [
      null_resource.custom_trigger
    ]
  }
}

resource "aws_api_gateway_gateway_response" "resp1_504" {
  rest_api_id   = var.api_gateway_id 
  status_code   = "503"
  response_type = "INTEGRATION_FAILURE"

  response_templates = {
    "application/json" = "{\"status\":503, \"errorType\": \"ServiceUnavailable\", \"errorReason\":\"The request has failed due to a temporary failure of the server.\"}"
  }
  response_parameters = var.gw_response_parameters
  lifecycle {
    create_before_destroy = false
    replace_triggered_by = [
      null_resource.custom_trigger
    ]
  }
}

resource "aws_api_gateway_gateway_response" "resp2_504" {
  rest_api_id   = var.api_gateway_id 
  status_code   = "503"
  response_type = "INTEGRATION_TIMEOUT"

  response_templates = {
    "application/json" = "{\"status\":503, \"errorType\": \"ServiceUnavailable\", \"errorReason\":\"The request has failed due to a temporary failure of the server.\"}"
  }
  response_parameters = var.gw_response_parameters
  lifecycle {
    create_before_destroy = false
    replace_triggered_by = [
      null_resource.custom_trigger
    ]
  }
}

resource "aws_api_gateway_gateway_response" "default4XX" {
  rest_api_id   = var.api_gateway_id
  status_code   = "400"
  response_type = "DEFAULT_4XX"

  response_templates = {
    "application/json" = "{\"status\":400, \"errorType\": \"InvalidAction\", \"errorReason\":\"The action or operation requested is invalid. Verify that the action is typed correctly.\"}"
    }
  response_parameters = var.gw_response_parameters
  lifecycle {
    create_before_destroy = false
    replace_triggered_by = [
      null_resource.custom_trigger
    ]
  }
}