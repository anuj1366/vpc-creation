variable "lambda_function_name" {
  description = "This is lambda function name"
  type        = string
  default     = ""
}
variable "lambda_function_memory" {
  description = "This is lambda function name containing lambda function"
  type        = number
  default     = 256
}

variable "lambda_role" {
  description = "please provide the lambda_role_arn"
  type        = string
  default     = ""
}

variable "lambda_description" {
  description = "please provide the description for lambda function"
  type        = string
  default     = ""
}

variable "lambda_handler" {
  description = "Lambda handler list"
  type        = string
  default     = "lambda_function"
}

variable "env" {
  description = "Lambda Environment Variables"
  type        = string
  default     = ""
}


variable "lambda_env_variables" {
}

variable "common_tags"{}

variable "iam_role_name" {
  type    = string
  default = ""
}

variable "iaminlinepolicy" {
  type    = string
  default = ""
}

variable "priority"{
  type    = string
  default = "P1"
}

variable "lambda_timeout" {
  default = "300"
}