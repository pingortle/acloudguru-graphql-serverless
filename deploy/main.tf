provider "aws" {}

terraform {
  backend "s3" {
    bucket     = "tfstate-acg-serverless-graphql-phase3-7873a7db07c0df4fcd283cf1b"
    key        = "terraform.tfstate"
    region     = "us-east-1"
  }
}

locals {
  app_name     = "acg-serverless-graphql-phase3"
  project_root = "${path.module}/.."
  source_dir   = "${local.project_root}/src"
}

module "api" {
  source     = "./lambda-api"
  app_name   = "${local.app_name}"
}

module "api_actions" {
  source             = "./api-actions"
  app_name           = "${local.app_name}"
  stage              = "staging"
  lambda_role_arn    = "${module.lambda_role.arn}"
  rest_api_id        = "${module.api.rest_api_id}"
  root_resource_id   = "${module.api.root_resource_id}"
}

resource "aws_api_gateway_deployment" "Deployment" {
  depends_on = [
    "module.api_actions"
  ]

  rest_api_id = "${module.api.rest_api_id}"
  stage_name  = "staging"
}

module "lambda_role" {
  source = "./basic-lambda-role"
  name = "${local.app_name}Role"
}
