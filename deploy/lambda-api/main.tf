variable "app_name" {}
variable "binary_media_types" { default = [] }

output "rest_api_id" { value = "${aws_api_gateway_rest_api.API.id}" }
output "root_resource_id" { value = "${aws_api_gateway_rest_api.API.root_resource_id}" }

resource "aws_api_gateway_rest_api" "API" {
  name               = "${var.app_name}API"
  description        = "An API called ${var.app_name}"
  binary_media_types = "${var.binary_media_types}"
}

data "aws_caller_identity" "current" {}
