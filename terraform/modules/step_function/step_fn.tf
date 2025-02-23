resource "aws_sfn_state_machine" "sfn_state_machine" {
  name         = var.step_func_name
  definition  = var.definition
  role_arn = aws_iam_role.iam_role.arn
  tags = merge(
    var.common_tags,
    {
      Name = var.step_func_name,
      environment = var.env
    }
  )
  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.log_group.arn}:*" 
    include_execution_data = true
    level                  = "ERROR"
  }
  tracing_configuration {
    enabled = true
  }
  depends_on = [ 
    aws_cloudwatch_log_group.log_group,
    aws_iam_role.iam_role 
    ]
} 

#-----------------------------------------------------------
# Step Function Cloudwatch
#-----------------------------------------------------------
resource "aws_cloudwatch_log_group" "log_group" {
  name              = format("%s%s", "/aws/vendedlogs/states/", var.step_func_name)
  retention_in_days = 90
  kms_key_id        = var.cmk_kms_arn

  tags = merge(
    var.common_tags,
    {
      Name        = format("%s%s", "/aws/vendedlogs/states/", var.step_func_name),
      environment = var.env
    }
  )
}

#-----------------------------------------------------------
#Step Function IAM Role
#-----------------------------------------------------------
resource "aws_iam_role" "iam_role" {
  name                  = var.iam_role_name
  path                  = "/"
  force_detach_policies = true
  assume_role_policy    = data.aws_iam_policy_document.stepfn_assume_policy.json
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


data "aws_iam_policy_document" "stepfn_assume_policy" {
  policy_id = "assumepolicy"
  statement {
    sid    = "First"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}