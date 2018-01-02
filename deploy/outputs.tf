output "url" {
  value = "${aws_api_gateway_deployment.Deployment.invoke_url}"
}

output "static_site_bucket" {
  value = "${module.static_site.bucket}"
}
