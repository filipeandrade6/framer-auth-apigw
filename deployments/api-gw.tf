provider "aws" {
  region = "us-east-1"
}

resource "aws_api_gateway_rest_api" "fiap44" {
    name = "fiap44-apigw"

    endpoint_configuration {
        types = ["REGIONAL"]
    }
}

resource "aws_api_gateway_authorizer" "fiap44" {
  name                   = "fiap44"
  rest_api_id            = aws_api_gateway_rest_api.fiap44.id
  type = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.fiap44.arn]
}

#####
## upload (lambda)
#####

resource "aws_api_gateway_resource" "upload" {
    rest_api_id = aws_api_gateway_rest_api.fiap44.id
    parent_id = aws_api_gateway_rest_api.fiap44.root_resource_id
    path_part = "upload"
}

resource "aws_api_gateway_method" "upload" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.upload.id
  http_method = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.fiap44.id
}

resource "aws_api_gateway_integration" "upload" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.upload.id
  http_method = aws_api_gateway_method.upload.http_method
  integration_http_method = "GET"
  type = "AWS_PROXY"
  uri = data.aws_lambda_function.fiap44_framer_psgr_upload.invoke_arn
}

resource "aws_api_gateway_method_response" "upload" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.upload.id
  http_method = aws_api_gateway_method.upload.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "upload" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.upload.id
  http_method = aws_api_gateway_method.upload.http_method
  status_code = aws_api_gateway_method_response.upload.status_code

  depends_on = [
    aws_api_gateway_method.upload,
    aws_api_gateway_integration.upload,
  ]
}

#####
## download (lambda)
#####

resource "aws_api_gateway_resource" "download" {
    rest_api_id = aws_api_gateway_rest_api.fiap44.id
    parent_id = aws_api_gateway_rest_api.fiap44.root_resource_id
    path_part = "download"
}

resource "aws_api_gateway_method" "download" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.download.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.fiap44.id
}

resource "aws_api_gateway_integration" "download" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.download.id
  http_method = aws_api_gateway_method.download.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = data.aws_lambda_function.fiap44_framer_psgr_download.invoke_arn
}

resource "aws_api_gateway_method_response" "download" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.download.id
  http_method = aws_api_gateway_method.download.http_method
  status_code = "204"
}

resource "aws_api_gateway_integration_response" "download" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.download.id
  http_method = aws_api_gateway_method.download.http_method
  status_code = aws_api_gateway_method_response.download.status_code

  depends_on = [
    aws_api_gateway_method.download,
    aws_api_gateway_integration.download,
  ]
}

#####
## api gw deploy
#####

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.upload,
    aws_api_gateway_integration.download,
  ]

  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  stage_name = "v1"
}

resource "aws_lambda_permission" "fiap44_framer_psgr_upload" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.fiap44_framer_psgr_upload.function_name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.fiap44.execution_arn}/*"
}

resource "aws_lambda_permission" "fiap44_framer_psgr_download" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.fiap44_framer_psgr_download.function_name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.fiap44.execution_arn}/*"
}

data "aws_lambda_function" "fiap44_framer_psgr_upload" {
  function_name = "fiap44_framer_psgr_upload"
}

data "aws_lambda_function" "fiap44_framer_psgr_download" {
  function_name = "fiap44_framer_psgr_download"
}