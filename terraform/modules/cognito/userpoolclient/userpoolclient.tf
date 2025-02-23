resource "aws_cognito_user_pool_client" "default" {
  name                                          = var.client_name
  refresh_token_validity                        = var.refresh_token_validity
  supported_identity_providers                  = var.supported_identity_providers
  callback_urls                                 = var.callback_urls
  generate_secret                               = false
  allowed_oauth_flows                           = var.allowed_oauth_flows
  explicit_auth_flows                           = var.explicit_auth_flows
  allowed_oauth_scopes                          = var.allowed_oauth_scopes
  allowed_oauth_flows_user_pool_client          = var.allowed_oauth_flows_user_pool_client
  enable_token_revocation                       = var.enable_token_revocation
  enable_propagate_additional_user_context_data = var.enable_propagate_additional_user_context_data
  user_pool_id                                  = var.user_pool_id
}
