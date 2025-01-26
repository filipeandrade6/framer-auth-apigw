resource "aws_cognito_user_pool" "fiap44" {
    name = "fiap44"
    alias_attributes = ["email"]

    password_policy {
      minimum_length = 6
    }

    account_recovery_setting {
        recovery_mechanism {
        name     = "verified_email"
        priority = 1
        }
    }

    tags = {
      "Name" = "fiap44"
    }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "client"

  user_pool_id = aws_cognito_user_pool.fiap44.id
  callback_urls = ["http://localhost"]

  generate_secret     = true
  explicit_auth_flows = [ "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["implicit"]
  allowed_oauth_scopes = ["email", "openid"]
  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "fiap44" {
  domain       = "fiap44"
  user_pool_id = aws_cognito_user_pool.fiap44.id
}
