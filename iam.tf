resource "aws_iam_user" "circleci_user" {
  name = "CircleCIUser"
  path = "/twizar/"
}

resource "aws_iam_user_policy_attachment" "circleci_user_policy_attachments" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AWSLambda_FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonCognitoReadOnly",
    "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ])
  policy_arn = each.value

  user       = aws_iam_user.circleci_user.name
}

resource "aws_iam_role" "cognito_authenticated_role" {
  name = "CognitoAuthenticatedRole"

  assume_role_policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Effect" = "Allow",
        "Principal" = {
          "Federated" = "cognito-identity.amazonaws.com"
        },
        "Action" = "sts:AssumeRoleWithWebIdentity",
        "Condition" = {
          "StringEquals" = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.twizar_cognito_identity_pool.id
          },
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })

}

resource "aws_iam_role_policy" "cognito_authenticated_policy" {
  name = "CognitoAuthenticatedPolicy"
  role = aws_iam_role.cognito_authenticated_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "mobileanalytics:PutEvents",
          "cognito-sync:*",
          "cognito-identity:*"
        ],
        "Resource": [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "cognito_regular_users_group_role" {
  name = "RegularUsersRole"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "cognito-identity.amazonaws.com"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "cognito-identity.amazonaws.com:aud": aws_cognito_identity_pool.twizar_cognito_identity_pool.id
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "regular_users_role_policy" {
  name = "RegularUsersRolePolicy"
  role = aws_iam_role.cognito_regular_users_group_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "cognito-idp:ListUsers"
        ],
        //"Resource": "*"
        "Resource": aws_cognito_user_pool.twizar_cognito_user_pool.arn
      }
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
  name = "LambdaRole"

  assume_role_policy =  jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      },
    ]
  })
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name = "LambdaRolePolicy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "cognito-idp:AdminAddUserToGroup"
        ],
        "Resource": aws_cognito_user_pool.twizar_cognito_user_pool.arn
      },
      {
        "Effect": "Allow",
        "Action": [
          "lambda:InvokeFunction",
          "lambda:InvokeAsync",
        ],
        "Resource": "arn:aws:lambda:eu-central-1:982516328771:function:*"
      }
    ]
  })
}

resource aws_iam_role_policy_attachment lambda_role_policy_attachements {
  for_each = toset([
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  ])

  role       = aws_iam_role.lambda_role.name
  policy_arn = each.value
}
