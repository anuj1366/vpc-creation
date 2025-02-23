##########################################################################
# App client settings
##########################################################################

variable "client_name" {
  description = "(Required) Name of the application client."
}

variable "user_pool_id" {
  description = "User pool the client belongs to"
}

variable "refresh_token_validity" {
  description = "Time limit in days refresh tokens are valid for."
}

variable "allowed_oauth_flows" {
  description = "(Optional) List of allowed OAuth flows (code, implicit, client_credentials)."
  type        = list(string)
  default     = []
}

variable "explicit_auth_flows" {
  description = "(Optional) List of authentication flows (ADMIN_NO_SRP_AUTH, CUSTOM_AUTH_FLOW_ONLY, USER_PASSWORD_AUTH, ALLOW_ADMIN_USER_PASSWORD_AUTH, ALLOW_CUSTOM_AUTH, ALLOW_USER_PASSWORD_AUTH, ALLOW_USER_SRP_AUTH, ALLOW_REFRESH_TOKEN_AUTH)"
  type        = list(string)
  default     = []
}


variable "allowed_oauth_flows_user_pool_client" {
  description = "(Optional) Whether the client is allowed to follow the OAuth protocol when interacting with Cognito user pools."
  default     = true
}

variable "allowed_oauth_scopes" {
  description = "(Optional) List of allowed OAuth scopes (phone, email, openid, profile, and aws.cognito.signin.user.admin)."
  type        = list(string)
  default     = []
}

variable "callback_urls" {
  description = "(Optional) List of allowed callback URLs for the identity providers."
  type        = list(string)
  default     = []
}

variable "logout_urls" {
  description = "(Optional) List of allowed logout URLs for the identity providers."
  type        = list(string)
  default     = []
}

variable "supported_identity_providers" {
  description = "(Optional) List of provider names for the identity providers that are supported on this client."
  type        = list(string)
  default     = []
}

variable "enable_token_revocation" {
  description = "Enables or disables token revocation."
  type        = string
  default     = false
}

variable "enable_propagate_additional_user_context_data" {
  description = "Activates the propagation of additional user context data."
  type        = string
  default     = false
}





