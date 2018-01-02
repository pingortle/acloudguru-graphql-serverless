variable "domain_name" {}
variable "certificate_arn" { default = "" }

variable "index_document" { default = "index.html" }
variable "error_document" { default = "404.html" }
variable "bucket_path" { default = "" }

variable "price_class" {
  description   = "Determines which edge locations are available to the CDN (Options: 'PriceClass_All', 'PriceClass_200', 'PriceClass_100')"
  default       = "PriceClass_100"
}

variable "log_cookies" { default = "false" }
variable "origin_suffix" { default = "origin" }
variable "forward_query_string" { default = "false" }
variable "forward_cookies" { default = "none" }
variable "viewer_protocol_policy" { default = "allow-all" }
variable "min_ttl" { default = "0" }
variable "default_ttl" { default = "3600" }
variable "max_ttl" { default = "86400" }
variable "cache_allowed_methods" { default = "DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT" }
variable "cache_cached_methods" { default = "GET,HEAD" }

variable "geo_restriction_type" { default = "none" }
