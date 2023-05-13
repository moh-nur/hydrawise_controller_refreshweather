variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "path_source_code" {
  default = "src"
}

variable "function_name" {
  default = "hydrawise_weather_refresher"
}

variable "runtime" {
  default = "python3.8"
}

variable "output_path" {
  description = "Path to function's deployment package into local filesystem"
  default = "lambda_function.zip"
}

variable "lambda_function_name" {
  description = "Python script to set and unset your weather station for the Hydrawise irrigation controller."
  default     = "hydrawise-controller-refreshweather"
}

variable "hydrawise_username" {
  description = "Hydrawise username"
}

variable "hydrawise_password" {
  description = "Hydrawise password"
}

variable "hydrawise_client_secret" {
  description = "Hydrawise client secret"
}

variable "hydrawise_controller_id" {
  description = "Hydrawise controller id"
}

variable "hydrawise_weatherstation_id" {
  description = "Hydrawise weather station you'd like to refresh"
}

terraform {
  backend "s3" {
    bucket = "hydrawise-controller-refresh-tf"
    key    = "terraform/state.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

resource "null_resource" "lambda_build" {
  triggers = {
    handler      = base64sha256(file("src/lambda.py"))
    requirements = base64sha256(file("src/requirements.txt"))
    build        = base64sha256(file("src/build.sh"))
  }

  provisioner "local-exec" {
    command = "${path.module}/src/build.sh"
    environment = {
      source_code_path = var.path_source_code
      function_name    = var.function_name
      path_module      = path.module
      runtime          = var.runtime
      path_cwd         = path.cwd
    }
  }
}

data "archive_file" "lambda_zip" {
  source_dir  = "src/dist"
  output_path = "/tmp/lambda.zip"
  type        = "zip"

  depends_on = [
    null_resource.lambda_build
  ]
}

resource "aws_lambda_function" "python_lambda" {
  function_name    = var.lambda_function_name
  runtime          = var.runtime
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_execution_role.arn
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  filename         = data.archive_file.lambda_zip.output_path

  environment {
    variables = {
      HYDRAWISE_USERNAME         = var.hydrawise_username
      HYDRAWISE_PASSWORD         = var.hydrawise_password
      HYDRAWISE_CLIENT_SECRET    = var.hydrawise_client_secret
      HYDRAWISE_CONTROLLERID     = var.hydrawise_controller_id
      HYDRAWISE_WEATHERSTATIONID = var.hydrawise_weatherstation_id
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_execution_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}

resource "aws_cloudwatch_event_rule" "lambda_event_rule" {
  name                = "lambda-event-rule"
  schedule_expression = "cron(30 3,8 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_event_target" {
  rule = aws_cloudwatch_event_rule.lambda_event_rule.name
  arn  = aws_lambda_function.python_lambda.arn
}