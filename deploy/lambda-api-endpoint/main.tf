locals {
  output_path            = "${path.module}/tmp/source.zip"
  should_create_resource = "${length(var.path_part) > 0}"
  created_resource_ids   = "${coalescelist(aws_api_gateway_resource.Resource.*.id, list(""))}"
  resource_id            = "${local.should_create_resource ? local.created_resource_ids[0] : var.parent_resource_id}"
  pattern                = "/[^{]*\\{(\\w+)\\}[^{]*/"
  replacement            = "$1,"
  path_parameters        = "${compact(split(",", replace(var.path_part, local.pattern, local.replacement)))}"
  request_parameter_keys = "${formatlist("method.request.path.%s", local.path_parameters)}"
  request_parameter_values = "${slice(split(",", replace(join(",", local.request_parameter_keys), "/[^,]+/", "true")), 0, length(local.request_parameter_keys))}"
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

  request_parameters = "${zipmap(local.request_parameter_keys, local.request_parameter_values)}"
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
