variable "ENV" {
  default     = "develop"
  type        = string
  description = "Environment Name"
}

variable "common_tags" {
  default = {
    "owner"                   = "DevTeam",
    "application"             = "create-vpc",
    "iac-type"            = "TF",
  }
  description = "Common resource tags"
  type        = map(string)
}