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

resource "aws_api_gateway_vpc_link" "fiap44-vpc-link" {
  name        = "fiap44-vpc-link"
  target_arns = [ "${data.aws_lb.fiap44-alb.arn}" ]
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
  http_method = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.fiap44.id
}

resource "aws_api_gateway_integration" "upload" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.upload.id
  http_method = aws_api_gateway_method.upload.http_method
  integration_http_method = "ANY"
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
## videos
#####

## aws_api_gateway_resource
resource "aws_api_gateway_resource" "videos" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  parent_id = aws_api_gateway_rest_api.fiap44.root_resource_id
  path_part = "videos"
}

resource "aws_api_gateway_resource" "videos_id" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  parent_id = aws_api_gateway_resource.videos.id
  path_part = "{id}"
  
}

resource "aws_api_gateway_resource" "videos_email" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  parent_id   = aws_api_gateway_resource.videos.id
  path_part   = "email"
}

resource "aws_api_gateway_resource" "videos_email_get" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  parent_id   = aws_api_gateway_resource.videos_email.id
  path_part   = "{email}"
}

resource "aws_api_gateway_method" "videos_list" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.videos.id
  http_method = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.fiap44.id
}

resource "aws_api_gateway_method" "videos_email_get" {
  rest_api_id   = aws_api_gateway_rest_api.fiap44.id
  resource_id   = aws_api_gateway_resource.videos_email_get.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.fiap44.id

  request_parameters = {
    "method.request.path.email" = true
  }
}

resource "aws_api_gateway_method" "videos_get" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.videos_id.id
  http_method = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.fiap44.id

  request_parameters = {
    "method.request.path.id" = true
  }
}

## aws_api_gateway_integration
resource "aws_api_gateway_integration" "videos_list" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.videos.id
  http_method = aws_api_gateway_method.videos_list.http_method
  integration_http_method = "GET"
  type = "HTTP"
  connection_type = "VPC_LINK"
  connection_id = aws_api_gateway_vpc_link.fiap44-vpc-link.id
  uri = "http://${data.aws_lb.fiap44-alb.dns_name}/videos"
}

resource "aws_api_gateway_integration" "videos_email_get" {
  rest_api_id             = aws_api_gateway_rest_api.fiap44.id
  resource_id             = aws_api_gateway_resource.videos_email_get.id
  http_method             = aws_api_gateway_method.videos_email_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.fiap44-vpc-link.id
  uri                     = "http://${data.aws_lb.fiap44-alb.dns_name}/videos/email/{email}"

  request_parameters = {
    "integration.request.path.email" = "method.request.path.email"
  }
}

resource "aws_api_gateway_integration" "videos_get" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.videos_id.id
  http_method = aws_api_gateway_method.videos_get.http_method
  integration_http_method = "GET"
  type = "HTTP"
  connection_type = "VPC_LINK"
  connection_id = aws_api_gateway_vpc_link.fiap44-vpc-link.id
  uri = "http://${data.aws_lb.fiap44-alb.dns_name}/videos/{id}"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
}

## aws_api_gateway_method_response
resource "aws_api_gateway_method_response" "videos_list" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.videos.id
  http_method = aws_api_gateway_method.videos_list.http_method
  status_code = "200"
}

resource "aws_api_gateway_method_response" "videos_email_get" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.videos_email_get.id
  http_method = aws_api_gateway_method.videos_email_get.http_method
  status_code = "200"
}

resource "aws_api_gateway_method_response" "videos_get" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.videos_id.id
  http_method = aws_api_gateway_method.videos_get.http_method
  status_code = "200"
}

## aws_api_gateway_integration_response
resource "aws_api_gateway_integration_response" "videos_list" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.videos.id
  http_method = aws_api_gateway_method.videos_list.http_method
  status_code = aws_api_gateway_method_response.videos_list.status_code

  depends_on = [
    aws_api_gateway_method.videos_list,
    aws_api_gateway_integration.videos_list,
  ]
}

resource "aws_api_gateway_integration_response" "videos_email_get" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.videos_email_get.id
  http_method = aws_api_gateway_method.videos_email_get.http_method
  status_code = aws_api_gateway_method_response.videos_email_get.status_code

  depends_on = [
    aws_api_gateway_method.videos_email_get,
    aws_api_gateway_integration.videos_email_get,
  ]
}

resource "aws_api_gateway_integration_response" "videos_get" {
  rest_api_id = aws_api_gateway_rest_api.fiap44.id
  resource_id = aws_api_gateway_resource.videos_id.id
  http_method = aws_api_gateway_method.videos_get.http_method
  status_code = aws_api_gateway_method_response.videos_get.status_code

  depends_on = [
    aws_api_gateway_method.videos_get,
    aws_api_gateway_integration.videos_get,
  ]
}

#####
## api gw deploy
#####

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.upload,
    aws_api_gateway_integration.download,
    aws_api_gateway_integration.videos_email_get,
    aws_api_gateway_integration.videos_get,
    aws_api_gateway_integration.videos_list
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

data "aws_lb" "fiap44-alb" {
  tags = {
    "kubernetes.io/service-name" = "default/ingress-nginx-controller"
  }
}