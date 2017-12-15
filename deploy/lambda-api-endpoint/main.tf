locals {
  output_path            = "${path.module}/tmp/source.zip"
  should_create_resource = "${length(var.path_part) > 0}"
  null_resource_ids      = [""]
  created_resource_ids   = "${coalescelist(aws_api_gateway_resource.Resource.*.id, local.null_resource_ids)}"
  resource_id            = "${local.should_create_resource ? local.created_resource_ids[0] : var.parent_resource_id}"
}

resource "aws_api_gateway_resource" "Resource" {
  count       = "${local.should_create_resource ? 1 : 0}"
  rest_api_id = "${var.rest_api_id}"
  parent_id   = "${var.parent_resource_id}"
  path_part   = "${var.path_part}"
}

resource "aws_api_gateway_method" "Method" {
  rest_api_id   = "${var.rest_api_id}"
  resource_id   = "${local.resource_id}"
  http_method   = "${var.http_method}"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "Integration" {
  rest_api_id             = "${var.rest_api_id}"
  resource_id             = "${local.resource_id}"
  http_method             = "${aws_api_gateway_method.Method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_arn}/invocations"
}

data "aws_region" "current" { current = true }
data "aws_caller_identity" "current" {}
