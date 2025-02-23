data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#-----------------------------------------------------------
#CloudWatch Loggroup
#-----------------------------------------------------------
resource "aws_cloudwatch_log_group" "log_group" {
  name              = format("%s%s", "/aws/lambda/", var.lambda_function_name)
  retention_in_days = 90
  tags = merge(
    var.common_tags,
    {
      Name        = format("%s%s", "/aws/lambda/", var.lambda_function_name),
      environment = var.env
    }
  )
}


#-----------------------------------------------------------
#Lambda Function IAM Role
#-----------------------------------------------------------
resource "aws_iam_role" "iam_role" {
  name                  = var.iam_role_name
  path                  = "/"
  force_detach_policies = true
  assume_role_policy    = data.aws_iam_policy_document.lambda_assume_policy.json
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

data "aws_iam_policy_document" "lambda_assume_policy" {
  policy_id = "assumepolicy"
  statement {
    sid    = "First"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

locals {
  function_name               = var.lambda_function_name
  function_source_dir =  "../../lambda/${var.lambda_function_name}"
                        
}
#-----------------------------------------------------------
#Lambda Function with environment variables
#-----------------------------------------------------------
resource "aws_lambda_function" "lambda" {
  filename         = "${local.function_source_dir}.zip"
  function_name    = var.lambda_function_name
  description      = var.lambda_description
  role             = aws_iam_role.iam_role.arn
  handler          = "${var.lambda_handler}.lambda_handler"
  source_code_hash = data.archive_file.function_zip.output_base64sha256
  runtime          = "python3.12"
  memory_size      = var.lambda_function_memory
  timeout          = var.lambda_timeout
  tags = merge(
    var.common_tags,
    {
      Name        = var.lambda_function_name,
      environment = var.env
    }
  )
  environment {
    variables = var.lambda_env_variables
  }
  depends_on = [aws_iam_role.iam_role, aws_iam_role_policy.policy_attachment, aws_cloudwatch_log_group.log_group]
}

data "archive_file" "function_zip" {
  source_dir  = local.function_source_dir
  type        = "zip"
  output_path = "${local.function_source_dir}.zip"
}
