output "domain_name" {
  value = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

output "distribution_id" {
  value = "${aws_cloudfront_distribution.s3_distribution.id}"
}

output "nameservers" {
  value = "${join(",", aws_route53_delegation_set.main.name_servers)}"
}

output "bucket" {
  value = "${local.bucket}"
}
