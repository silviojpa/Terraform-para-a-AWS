# Este código cria uma função Lambda simples em Python, um IAM Role para conceder permissões e um API Gateway para expor a função como um endpoint HTTP.
# Define o provider da AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Arquivo zip da função Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_content = "def lambda_handler(event, context):\n    return {'statusCode': 200, 'body': 'Hello from Lambda!'}"
  output_path = "lambda_function_payload.zip"
}

# Cria o IAM Role para a função Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_api_gateway_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Atribui permissões de log à função Lambda
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Cria a função Lambda
resource "aws_lambda_function" "hello_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "hello-lambda-function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.8"
}

# Cria o API Gateway
resource "aws_api_gateway_rest_api" "gateway" {
  name = "api-gateway-lambda-integration"
}

# Cria o recurso de API Gateway (o caminho da URL)
resource "aws_api_gateway_resource" "proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  parent_id   = aws_api_gateway_rest_api.gateway.root_resource_id
  path_part   = "{proxy+}"
}

# Cria o método ANY para o endpoint
resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.proxy_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

# Integração do API Gateway com a função Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.gateway.id
  resource_id             = aws_api_gateway_resource.proxy_resource.id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello_lambda.invoke_arn
}

# Permite que o API Gateway chame a função Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.gateway.execution_arn}/*/*"
}

# Implanta a API
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  # Cria um novo deployment quando a integração for alterada
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_integration.lambda_integration))
  }
  depends_on = [aws_api_gateway_integration.lambda_integration]
}

# Cria o Stage para o endpoint
resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  stage_name    = "dev"
}

# Exibe a URL do endpoint
output "api_gateway_url" {
  value = aws_api_gateway_stage.stage.invoke_url
}
