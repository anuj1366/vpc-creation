variable "env" {
  type    = string
  default = ""
}

variable "common_tags"{}

variable "attributes"{}

variable "dynamodb_name" {
  type    = string
  default = ""
}

variable "billing_mode" {
  type    = string
  default = ""
}

variable "hash_key" {
  type    = string
  default = ""
}

variable "server_side_encryption" {
  type    = string
  default = ""
}

variable "view_type" {
  type = string
  default = ""
}

variable "range_key" {
  type = string
  default = null
}

variable "attributes_rangekey"{
  type = object({
    name = string
  })
  default = {
      name = ""
    }
}
