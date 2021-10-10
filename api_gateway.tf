# === Common === #
resource "aws_api_gateway_rest_api" "api_gateway_twizar" {
  name = "ApiGatewayTwizar"
}
resource "aws_api_gateway_authorizer" "user_pools_twizar_authorizer" {
  name          = "CognitoUserPoolTwizarAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_twizar.id
  provider_arns = data.aws_cognito_user_pools.twizar_cognito_user_pools_data.arns
}
resource "aws_api_gateway_deployment" "api_gateway_twizar_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_twizar.id

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.api_gateway_twizar_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_twizar.id
  stage_name    = var.api_gateway_stage_name
}
output api_gateway_stage_invoke_url {
  value = aws_api_gateway_stage.stage.invoke_url
}

# === Teams === #
resource "aws_api_gateway_resource" "resource_teams" {
  parent_id   = aws_api_gateway_rest_api.api_gateway_twizar.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api_gateway_twizar.id
  path_part   = "teams"
}
resource "aws_api_gateway_method" "api_gateway_method_teams" {
  authorization = "COGNITO_USER_POOLS"
  http_method   = "ANY"
  resource_id   = aws_api_gateway_resource.resource_teams.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_twizar.id
  authorizer_id = aws_api_gateway_authorizer.user_pools_twizar_authorizer.id
}
resource aws_api_gateway_method api_gateway_method_options_teams {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.resource_teams.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_twizar.id
}
resource aws_api_gateway_method_response teams_options_200 {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_twizar.id
  resource_id   = aws_api_gateway_resource.resource_teams.id
  http_method   = aws_api_gateway_method.api_gateway_method_options_teams.http_method
  status_code   = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}
resource aws_api_gateway_integration teams_options_integration  {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_twizar.id
  resource_id = aws_api_gateway_resource.resource_teams.id
  http_method = aws_api_gateway_method.api_gateway_method_options_teams.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}
resource aws_api_gateway_integration_response teams_options_integration_response {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_twizar.id
  resource_id = aws_api_gateway_resource.resource_teams.id
  http_method = aws_api_gateway_method.api_gateway_method_options_teams.http_method
  status_code   = aws_api_gateway_method_response.teams_options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'${var.http_header_access_control_allow_origin}'"
  }
  response_templates = {
    "application/json" = ""
  }
}
resource "aws_api_gateway_integration" "twizar_teams_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_twizar.id
  resource_id             = aws_api_gateway_resource.resource_teams.id
  http_method             = aws_api_gateway_method.api_gateway_method_teams.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_teams.invoke_arn
}
resource "aws_api_gateway_method_response" "twizar_method_response_teams" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_twizar.id
  resource_id             = aws_api_gateway_resource.resource_teams.id
  http_method             = aws_api_gateway_method.api_gateway_method_teams.http_method
  status_code             = 200

  response_models = {
    "application/json" = "Empty"
  }
}
resource "aws_api_gateway_integration_response" "twizar_integration_response_teams" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_twizar.id
  resource_id             = aws_api_gateway_resource.resource_teams.id
  http_method             = aws_api_gateway_method.api_gateway_method_teams.http_method
  status_code             = aws_api_gateway_method_response.twizar_method_response_teams.status_code
}

# === Tourneys === #
resource "aws_api_gateway_resource" "resource_tourneys" {
  parent_id   = aws_api_gateway_rest_api.api_gateway_twizar.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api_gateway_twizar.id
  path_part   = "tourneys"
}
resource "aws_api_gateway_method" "api_gateway_method_tourneys" {
  authorization = "COGNITO_USER_POOLS"
  http_method   = "ANY"
  resource_id   = aws_api_gateway_resource.resource_tourneys.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_twizar.id
  authorizer_id = aws_api_gateway_authorizer.user_pools_twizar_authorizer.id
}
resource "aws_api_gateway_integration" "twizar_tourneys_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_twizar.id
  resource_id             = aws_api_gateway_resource.resource_tourneys.id
  http_method             = aws_api_gateway_method.api_gateway_method_tourneys.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_tourneys.invoke_arn
}
resource "aws_api_gateway_method_response" "twizar_method_response_tourneys" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_twizar.id
  resource_id             = aws_api_gateway_resource.resource_tourneys.id
  http_method             = aws_api_gateway_method.api_gateway_method_tourneys.http_method
  status_code             = 200

  response_models = {
    "application/json" = "Empty"
  }
}
resource "aws_api_gateway_integration_response" "twizar_integration_response_tourneys" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_twizar.id
  resource_id             = aws_api_gateway_resource.resource_tourneys.id
  http_method             = aws_api_gateway_method.api_gateway_method_tourneys.http_method
  status_code             = aws_api_gateway_method_response.twizar_method_response_tourneys.status_code
}
resource aws_api_gateway_method api_gateway_method_options_tourneys {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.resource_tourneys.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_twizar.id
}
resource aws_api_gateway_method_response tourneys_options_200 {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_twizar.id
  resource_id   = aws_api_gateway_resource.resource_tourneys.id
  http_method   = aws_api_gateway_method.api_gateway_method_options_tourneys.http_method
  status_code   = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}
resource aws_api_gateway_integration tourneys_options_integration  {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_twizar.id
  resource_id = aws_api_gateway_resource.resource_tourneys.id
  http_method = aws_api_gateway_method.api_gateway_method_options_tourneys.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}
resource aws_api_gateway_integration_response tourneys_options_integration_response {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_twizar.id
  resource_id = aws_api_gateway_resource.resource_tourneys.id
  http_method = aws_api_gateway_method.api_gateway_method_options_tourneys.http_method
  status_code   = aws_api_gateway_method_response.tourneys_options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'${var.http_header_access_control_allow_origin}'"
  }
  response_templates = {
    "application/json" = ""
  }
}
