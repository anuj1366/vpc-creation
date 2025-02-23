variable "integration_lambda_name" {
  description = "This is integration lambda function name for API calls."
  type        = list
  default     = []
}

variable "env" {
  description = "Lambda Environment Variables"
  type        = string
  default     = ""
}

variable "common_tags" {}

variable "iam_role_name" {
  type    = string
  default = ""
}


variable "api_name" {
  type    = string
}

variable "endpoint_config" {
  type    = string
}

variable "stage_name" {
  type    = string
}

variable "iaminlinepolicy" {
  type    = string
}


variable "integration_lambda_source_path" {
  description = "This is the API execution source arn path."
  type        = list
  default     = []
}

variable "template_variables" {}

variable "priority" {
  type    = string
  default = "P1"
}