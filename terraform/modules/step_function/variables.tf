variable "env" {
  type    = string
  default = ""
}

variable "step_func_name" {
  type    = string
  default = ""
}

variable "definition" {
  type    = string
  default = ""
}

variable "iam_role_name" {
  type    = string
  default = ""
}

variable "iaminlinepolicy" {
  type    = string
  default = ""
}

variable "cmk_kms_arn" {
  type    = string
  default = ""
}

variable "priority"{
  type    = string
  default = "P1"
}

variable "common_tags"{}