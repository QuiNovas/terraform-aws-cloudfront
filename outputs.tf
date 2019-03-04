output "distribution_arn" {
  description = "The ARN (Amazon Resource Name) for the distribution. For example: arn:aws:cloudfront::123456789012:distribution/EDFDVBD632BHDS5, where 123456789012 is your AWS account ID."
  value       = "${local.cloudfront_default_certificate ? aws_cloudfront_distribution.distribution_with_default.*.arn[0] : aws_cloudfront_distribution.distribution.*.arn[0]}"
}

output "distribution_domain_name" {
  description = "The domain name corresponding to the distribution. For example: d604721fxaaqy9.cloudfront.net."
  value       = "${local.cloudfront_default_certificate ? aws_cloudfront_distribution.distribution_with_default.*.domain_name[0] : aws_cloudfront_distribution.distribution.*.domain_name[0]}"
}

output "distribution_hosted_zone_id" {
  description = "The CloudFront Route 53 zone ID that can be used to route an Alias Resource Record Set to. This attribute is simply an alias for the zone ID Z2FDTNDATAQYW2."
  value       = "${local.cloudfront_default_certificate ? aws_cloudfront_distribution.distribution_with_default.*.hosted_zone_id[0] : aws_cloudfront_distribution.distribution.*.hosted_zone_id[0]}"
}

output "distribution_id" {
  description = "The identifier for the distribution. For example: EDFDVBD632BHDS5."
  value       = "${local.cloudfront_default_certificate ? aws_cloudfront_distribution.distribution_with_default.*.id[0] : aws_cloudfront_distribution.distribution.*.id[0]}"
}

output "manage_policy_arn" {
	description = "The ARN of the management policy. Will be of format arn:aws:iam:::policy/policyname"
  value       = "${aws_iam_policy.manage.arn}"
}

output "origin_bucket" {
  description = "The name of the orgin bucket."
  value       = "${aws_s3_bucket.origin.id}"
}

output "origin_bucket_arn" {
  description = "The ARN of the origin bucket. Will be of format arn:aws:s3:::bucketname."
  value       = "${aws_s3_bucket.origin.arn}"
}
