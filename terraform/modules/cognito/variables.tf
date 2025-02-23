variable "user_pool_name" {
  description = "(Required) Name of the Cognito User Pool"
}




variable "password_policy_minimum_length" {
  description = "Minimum length of the password policy that you have set."
}

variable "password_policy_require_lowercase" {
  description = "Whether you have required users to use at least one lowercase letter in their password"
}

variable "password_policy_require_numbers" {
  description = "Whether you have required users to use at least one number in their password."
}

variable "password_policy_require_symbols" {
  description = "Whether you have required users to use at least one symbol in their password."
}

variable "password_policy_require_uppercase" {
  description = "Whether you have required users to use at least one uppercase letter in their password"
}

variable "password_policy_temporary_password_validity_days" {
  description = "In the password policy you have set, refers to the number of days a temporary password is valid. If the user does not sign-in during this time, their password will need to be reset by an administrator."
}

variable "user_pool_mfa_configuration" {
  description = "Multi-Factor Authentication (MFA) configuration for the User Pool"
}

variable "auto_verified_attributes" {
  description = "Attributes to be auto-verified. Valid values: email, phone_number"
  type        = list(string)
  default     = []
}

variable "username_attributes" {
  description = "Whether email addresses or phone numbers can be specified as usernames when a user signs up"
  type        = list(string)
  default     = []
}



variable "device_configuration_challenge_required_on_new_device" {
  description = "Indicates whether a challenge is required on a new device. Only applicable to a new device"
  type        = bool
  default     = false
}

variable "device_configuration_device_only_remembered_on_user_prompt" {
  description = "If true, a device is only remembered on user prompt"
  type        = bool
  default     = false
}

variable "email_configuration_configuration_set" {
  description = "The name of the configuration set"
  type        = string
  default     = null
}

variable "email_configuration_email_sending_account" {
  description = "Instruct Cognito to either use its built-in functional or Amazon SES to send out emails. Allowed values: `COGNITO_DEFAULT` or `DEVELOPER`"
  type        = string
  default     = "COGNITO_DEFAULT"
}

variable "email_configuration_from_email_address" {
  description = "Sender’s email address or sender’s display name with their email address (e.g. `john@example.com`, `John Smith <john@example.com>` or `\"John Smith Ph.D.\" <john@example.com>)`. Escaped double quotes are required around display names that contain certain characters as specified in RFC 5322"
  type        = string
  default     = null
}

variable "email_configuration_reply_to_email_address" {
  description = "The REPLY-TO email address"
  type        = string
  default     = ""
}

variable "email_configuration_source_arn" {
  description = "ARN of the SES verified email identity to to use. Required if email_sending_account is set to DEVELOPER"
  type        = string
  default     = ""
}

variable "advanced_security_mode" {
  description = "Mode for advanced security, must be one of OFF, AUDIT or ENFORCED"
  type        = string
  default     = "OFF"
}

variable "env" {
  type    = string
  default = ""
}

variable "common_tags" {}

variable "cognito_user_groups" {
  description = "Cognito User Groups List"
  type        = list(string)
  default     = []
}

variable "cognito_user_groups_desc" {
  description = "Cognito User Groups Description List"
  type        = list(string)
  default     = []
}

variable "deletion_protection" {
  description = "Cognito delete protection flag"
  type        = string
  default     = "INACTIVE"
}

variable "domain_name" {
  type = string
}