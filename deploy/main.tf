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

data "aws_route53_zone" "selected" {
  name = "lape.pw."
}

data "aws_acm_certificate" "selected" {
  domain   = "l.lape.pw"
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "root" {
  domain   = "lape.pw"
  statuses = ["ISSUED"]
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
  name   = "${local.app_name}Role"
}

module "staging_slug_table" {
  source = "./slug-table"
  stage = "staging"
}

module "static_site" {
  source                  = "./cdn"
  certificate_arn         = "${data.aws_acm_certificate.root.arn}"
  domain_name            = "linksocial.lape.pw"
}

resource "aws_route53_record" "staging" {
  zone_id = "${data.aws_route53_zone.selected.id}"

  name = "${aws_api_gateway_domain_name.staging.domain_name}"
  type = "A"

  alias {
    name                   = "${aws_api_gateway_domain_name.staging.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.staging.cloudfront_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_api_gateway_domain_name" "staging" {
  domain_name     = "l.lape.pw"
  certificate_arn = "${data.aws_acm_certificate.selected.arn}"
}

resource "aws_api_gateway_base_path_mapping" "staging" {
  api_id      = "${module.api.rest_api_id}"
  stage_name  = "${aws_api_gateway_deployment.Deployment.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.staging.domain_name}"
}
