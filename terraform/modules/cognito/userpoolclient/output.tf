output "id" {
  value     = aws_cognito_user_pool_client.default.id
  sensitive = true
}
