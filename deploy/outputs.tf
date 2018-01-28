output "url" {
  value = "${aws_api_gateway_deployment.Deployment.invoke_url}"
}

output "static_site_bucket" {
  value = "${module.static_site.bucket}"
}

output "cloudfront_distribution_id" {
  value = "${module.static_site.distribution_id}"
}

output "user_pool_id" {
  value = "${module.auth.user_pool_id}"
}
