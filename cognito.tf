resource "aws_cognito_user_pool" "twizar_cognito_user_pool" {
  name = "twizar"
  auto_verified_attributes = ["email"]
  username_attributes = ["email"]

  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }

  lambda_config {
    post_confirmation = aws_lambda_function.lambda_users.arn
  }

}

output user_pool_id {
  value = aws_cognito_user_pool.twizar_cognito_user_pool.id
}

resource "aws_cognito_user_group" "regular_users_group" {
  name         = var.lambda_users_regular_group
  user_pool_id = aws_cognito_user_pool.twizar_cognito_user_pool.id
  role_arn     = aws_iam_role.cognito_regular_users_group_role.arn
}

resource "aws_cognito_user_pool_domain" "main" {
  domain = "twizar"
  user_pool_id = aws_cognito_user_pool.twizar_cognito_user_pool.id
}

resource "aws_cognito_identity_provider" "google_identity_provider" {
  user_pool_id  = aws_cognito_user_pool.twizar_cognito_user_pool.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "email"
    client_id        = var.google_client_id
    client_secret    = var.google_client_client_secret
    attributes_url                = "https://people.googleapis.com/v1/people/me?personFields="
    attributes_url_add_attributes = true
    authorize_url                 = "https://accounts.google.com/o/oauth2/v2/auth"
    oidc_issuer                   = "https://accounts.google.com"
    token_request_method          = "POST"
    token_url                     = "https://www.googleapis.com/oauth2/v4/token"
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
}

resource "aws_cognito_identity_provider" "facebook_provider_identity_provider" {
  user_pool_id  = aws_cognito_user_pool.twizar_cognito_user_pool.id
  provider_name = "Facebook"
  provider_type = "Facebook"

  provider_details = {
    authorize_scopes = "email"
    client_id        = var.facebook_client_id
    client_secret    = var.facebook_client_client_secret
    attributes_url   = "https://graph.facebook.com/v6.0/me?fields="
    attributes_url_add_attributes  = true
    authorize_url                  = "https://www.facebook.com/v6.0/dialog/oauth"
    token_request_method           = "GET"
    token_url                      = "https://graph.facebook.com/v6.0/oauth/access_token"
  }

  attribute_mapping = {
    username = "id"
    email    = "email"
  }
}

resource "aws_cognito_user_pool_client" "web" {
  name = "web"

  user_pool_id = aws_cognito_user_pool.twizar_cognito_user_pool.id
}

data "aws_cognito_user_pools" "twizar_cognito_user_pools_data" {
  name = aws_cognito_user_pool.twizar_cognito_user_pool.name
}

resource "aws_cognito_identity_pool" "twizar_cognito_identity_pool" {
  identity_pool_name = "twizar"

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.web.id
    provider_name           = aws_cognito_user_pool.twizar_cognito_user_pool.endpoint
    server_side_token_check = false
  }

}

output identity_pool_id {
  value = aws_cognito_identity_pool.twizar_cognito_identity_pool.id
}

output user_pool_client_id {
  value = aws_cognito_user_pool_client.web.id
}

resource "aws_cognito_identity_pool_roles_attachment" "role_attachment" {
  identity_pool_id = aws_cognito_identity_pool.twizar_cognito_identity_pool.id

  role_mapping {
    identity_provider = "cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.twizar_cognito_user_pool.id}:${aws_cognito_user_pool_client.web.id}"
    ambiguous_role_resolution = "Deny"
    type                      = "Token"
  }

  roles = {
    "authenticated" = aws_iam_role.cognito_authenticated_role.arn
  }
}
