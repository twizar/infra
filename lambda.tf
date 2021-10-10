resource "aws_lambda_function" "lambda_teams" {
  filename      = var.lambda_stub_file
  function_name = "LambdaTeams"
  role          = aws_iam_role.lambda_role.arn
  handler       = "teams_bin"
  runtime       = "go1.x"

  environment {
    variables = {
      MONGO_CONN_URL = var.mongo_conn_url
      HTTP_HEADER_ACCESS_CONTROL_ALLOW_ORIGIN = var.http_header_access_control_allow_origin
    }
  }
}

resource "aws_lambda_function" "lambda_tourneys" {
  filename      = var.lambda_stub_file
  function_name = "LambdaTourneys"
  role          = aws_iam_role.lambda_role.arn
  handler       = "tourneys_bin"
  runtime       = "go1.x"

  environment {
    variables = {
      MONGO_CONN_URL = var.mongo_conn_url
      HTTP_HEADER_ACCESS_CONTROL_ALLOW_ORIGIN = var.http_header_access_control_allow_origin
      TEAMS_LAMBDA_NAME = aws_lambda_function.lambda_teams.function_name
      TEAMS_LAMBDA_ENDPOINT = "lambda.${var.aws_region}.amazonaws.com"
      TEAMS_LAMBDA_REGION = var.aws_region
    }
  }
}

resource "aws_lambda_function" "lambda_users" {
  filename      = var.lambda_stub_file
  function_name = "LambdaUsers"
  role          = aws_iam_role.lambda_role.arn
  handler       = "users_bin"
  runtime       = "go1.x"

  environment {
    variables = {
      REGULAR_USERS_GROUP = var.lambda_users_regular_group
    }
  }
}

resource "aws_lambda_permission" "lambda_teams_permission" {
  statement_id  = "AllowAPITeamsInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_teams.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.api_gateway_twizar.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "lambda_tourneys_permission" {
  statement_id  = "AllowAPITourneysInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_tourneys.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.api_gateway_twizar.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "lambda_users_permission" {
  statement_id  = "AllowCognitoUsersInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_users.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn = aws_cognito_user_pool.twizar_cognito_user_pool.arn
}
