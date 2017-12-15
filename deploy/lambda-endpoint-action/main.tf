variable "app_name" {}
variable "stage" {}
variable "http_method" {}
variable "source_dir" {}
variable "lambda_role_arn" {}
variable "rest_api_id" {}
variable "parent_resource_id" {}
variable "path_part" { default = "" }

locals {
  long_name          = "${var.app_name}-${var.http_method}-${md5("${var.path_part}")}"
  name               = "${substr(local.long_name, 0, 64)}"
  long_function_name = "CallAPI_${local.name}"
  function_name      = "${substr(local.long_function_name, 0, 64)}"
}

module "endpoint" {
  source             = "../lambda-api-endpoint"
  lambda_arn         = "${aws_lambda_function.API.arn}"
  rest_api_id        = "${var.rest_api_id}"
  parent_resource_id = "${var.parent_resource_id}"
  stage              = "${var.stage}"
  http_method        = "${var.http_method}"
  path_part          = "${var.path_part}"
}

resource "aws_lambda_alias" "API" {
  name             = "${local.function_name}"
  function_name    = "${aws_lambda_function.API.function_name}"
  function_version = "$LATEST"
}

resource "aws_lambda_function" "API" {
  filename         = "${data.archive_file.lambda_source.output_path}"
  function_name    = "${local.function_name}"
  role             = "${var.lambda_role_arn}"
  handler          = "lambda.handler"
  source_code_hash = "${data.archive_file.lambda_source.output_base64sha256}"
  runtime          = "nodejs6.10"
  timeout          = "30"

  environment {
    variables = {
      NODE_ENV = "production"
    }
  }
}

resource "aws_lambda_permission" "AllowAPI" {
  statement_id   = "AllowAPIInvocation-${var.app_name}-${var.rest_api_id}"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.API.arn}"
  principal      = "apigateway.amazonaws.com"
  source_arn     = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*/*/*"
}

data "archive_file" "lambda_source" {
  source_dir  = "${var.source_dir}"
  output_path = "${path.module}/tmp/${local.name}/lambda_source_archive.zip"
  type        = "zip"
}

data "aws_region" "current" { current = true }
data "aws_caller_identity" "current" {}
