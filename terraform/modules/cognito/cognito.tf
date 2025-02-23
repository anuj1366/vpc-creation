
resource "random_id" "random_external_id" {
  keepers = {
    first = "${timestamp()}"
  }
  byte_length = 8
}

## Create Role for SMS sending
data "aws_iam_policy_document" "sms_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cognito-idp.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["${random_id.random_external_id.hex}"]
    }
  }
}

resource "aws_iam_role" "sms_role" {
  name               = "${var.user_pool_name}-SMS-Role"
  assume_role_policy = data.aws_iam_policy_document.sms_assume_role_policy.json

  inline_policy {
    name = "cognito-idp-SMS-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["sns:publish"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
  tags = merge(
    var.common_tags,
    {
      environment = var.env
    }
  )
}


resource "aws_cognito_user_pool" "default" {
  name = var.user_pool_name
  password_policy {
    minimum_length                   = var.password_policy_minimum_length
    require_lowercase                = var.password_policy_require_lowercase
    require_numbers                  = var.password_policy_require_numbers
    require_symbols                  = var.password_policy_require_symbols
    require_uppercase                = var.password_policy_require_uppercase
    temporary_password_validity_days = var.password_policy_temporary_password_validity_days
  }
  auto_verified_attributes = var.auto_verified_attributes
  username_attributes      = var.username_attributes
  deletion_protection      = var.deletion_protection


  device_configuration {
    challenge_required_on_new_device      = var.device_configuration_challenge_required_on_new_device
    device_only_remembered_on_user_prompt = var.device_configuration_device_only_remembered_on_user_prompt
  }

  sms_configuration {
    external_id    = random_id.random_external_id.hex
    sns_caller_arn = aws_iam_role.sms_role.arn
  }

  tags = merge(
    var.common_tags,
    {
      Name        = var.user_pool_name,
      environment = var.env
    }
  )
}

resource "aws_cognito_user_pool_domain" "cognito_domain" {
  domain          = var.domain_name
  user_pool_id    = aws_cognito_user_pool.default.id
}