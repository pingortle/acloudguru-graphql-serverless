resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Origin access identity for my static websites"
}

locals {
  bucket = "${var.domain_name}"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    origin_path = "${var.bucket_path}"
    domain_name = "${local.bucket}.s3.amazonaws.com"
    origin_id   = "${var.domain_name}_${var.origin_suffix}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  enabled             = true
  comment             = "${var.domain_name} s3 distribution"
  default_root_object = "${var.index_document}"

  aliases = ["${var.domain_name}", "www.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods  = ["${split(",", var.cache_allowed_methods)}"]
    cached_methods   = ["${split(",", var.cache_cached_methods)}"]
    target_origin_id = "${var.domain_name}_${var.origin_suffix}"
    compress         = true

    forwarded_values {
      query_string = "${var.forward_query_string}"

      cookies {
        forward = "${var.forward_cookies}"
      }
    }

    viewer_protocol_policy = "${var.viewer_protocol_policy}"
    min_ttl                = "${var.min_ttl}"
    default_ttl            = "${var.default_ttl}"
    max_ttl                = "${var.max_ttl}"
  }

  price_class = "${var.price_class}"

  restrictions {
    geo_restriction {
      restriction_type = "${var.geo_restriction_type}"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = "${length(var.certificate_arn) == 0}"
    acm_certificate_arn            = "${var.certificate_arn}"
    ssl_support_method             = "sni-only"
  }
}

resource "aws_s3_bucket" "root_bucket" {
    bucket = "${local.bucket}"
    policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [{
    "Sid": "Allow Public Access to All Objects",
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::${var.domain_name}/*"
  }
 ]
}
EOF

    website {
        index_document = "${var.index_document}"
        error_document = "${var.error_document}"
    }

    cors_rule {
        allowed_headers = ["*"]
        allowed_methods = ["GET"]
        allowed_origins = ["*"]
        expose_headers = ["ETag"]
        max_age_seconds = 3000
    }

    tags {
        Name = "${var.domain_name} s3 bucket"
    }
}

locals {
  domain_name_parts = "${split(".", var.domain_name)}"
}

data "aws_route53_zone" "root_zone" {
  name = "${join(".", slice(local.domain_name_parts, length(local.domain_name_parts) - 2, length(local.domain_name_parts)))}."
}

resource "aws_route53_delegation_set" "main" {
    reference_name = "Static Websites"
}

resource "aws_route53_record" "production" {
  name           = "${var.domain_name}"
  zone_id        = "${data.aws_route53_zone.root_zone.zone_id}"
  type           = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.s3_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "production-www" {
  name           = "www.${var.domain_name}"
  zone_id        = "${data.aws_route53_zone.root_zone.zone_id}"
  type           = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.s3_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}
