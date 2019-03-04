locals {
  bucket_name                     = "${var.bucket_name == "" ? var.distribution_name : var.bucket_name}"
  cloudfront_default_certificate  = "${length(var.acm_certificate_arn) == 0}"
  tags                            = "${merge(var.tags, map("Name", "${var.distribution_name}"))}"
  viewer_certificate_base {
    minimum_protocol_version        = "${local.cloudfront_default_certificate ? "TLSv1" : "TLSv1.1_2016"}"
    ssl_support_method              = "sni-only"
  }
  viewer_certificate = "${local.cloudfront_default_certificate ? merge(local.viewer_certificate_base, map("cloudfront_default_certificate", local.cloudfront_default_certificate)) : merge(local.viewer_certificate_base, map("acm_certificate_arn", var.acm_certificate_arn))}"
}