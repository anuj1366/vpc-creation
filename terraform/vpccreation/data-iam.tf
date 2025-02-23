
data "aws_iam_policy_document" "iam-policy-lambda-get-vpc" {
  policy_id = "getvpcpolicy"

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:eu-central-1:${data.aws_caller_identity.current.id}:log-group:/aws/lambda/get_vpc_detail:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["dynamodb:GetItem"]
    resources = [module.dynamodb_store_vpc_data.arn, module.dynamodb_store_vpc_order.arn]
  }

}

data "aws_iam_policy_document" "iam-policy-lambda-createvpc" {
  policy_id = "createvpcpolicy"

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:eu-central-1:${data.aws_caller_identity.current.id}:log-group:/aws/lambda/create_vpc:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["dynamodb:PutItem"]
    resources = [module.dynamodb_store_vpc_data.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "iam-policy-lambda-createvpcorder" {
  policy_id = "getvpcpolicy"

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:eu-central-1:${data.aws_caller_identity.current.id}:log-group:/aws/lambda/vpc_creation_order:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["dynamodb:PutItem"]
    resources = [module.dynamodb_store_vpc_order.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:*"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "states:StartExecution"
    ]
    resources = [module.step_function_vpc_creation.step_func_arn]
  }

}

data "aws_iam_policy_document" "iam-policy-api-gateway-logs" {
  policy_id = "iampolicy1"

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "iam-policy-vpc-creation-Stepfn" {
  policy_id = "iampolicy1"

  statement {
    effect = "Allow"
    actions = [
      "logs:UpdateLogDelivery",
      "logs:PutResourcePolicy",
      "logs:PutLogEvents",
      "logs:ListLogDeliveries",
      "logs:GetLogDelivery",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups",
      "logs:DeleteLogDelivery",
      "logs:CreateLogStream",
      "logs:CreateLogDelivery"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
    "arn:aws:lambda:eu-central-1:${data.aws_caller_identity.current.id}:function:create_vpc"
    ]
  }

}