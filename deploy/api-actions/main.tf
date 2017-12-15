variable "app_name" {}
variable "stage" {}
variable "lambda_role_arn" {}
variable "rest_api_id" {}
variable "root_resource_id" {}

locals {
  src = "${path.root}/../src"
}

module "GET_index" {
  source             = "../lambda-endpoint-action"
  stage              = "${var.stage}"
  app_name           = "${var.app_name}"
  lambda_role_arn    = "${var.lambda_role_arn}"
  rest_api_id        = "${var.rest_api_id}"
  parent_resource_id = "${var.root_resource_id}"
  http_method        = "GET"
  source_dir         = "${local.src}/index/get"
}
