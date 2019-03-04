locals {
  bucket_name                     = "${var.bucket_name == "" ? var.distribution_name : var.bucket_name}"
  cloudfront_default_certificate  = "${length(var.acm_certificate_arn) == 0}"
  tags                            = "${merge(var.tags, map("Name", "${var.distribution_name}"))}"
}