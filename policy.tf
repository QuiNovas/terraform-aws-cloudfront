data "aws_iam_policy_document" "manage" {
	statement = {
		actions   = [
			"s3:AbortMultipartUpload",
			"s3:DeleteObject",
			"s3:DeleteObjectTagging",
			"s3:DeleteObjectVersion",
			"s3:DeleteObjectVersionTagging",
			"s3:GetObject",
			"s3:GetObjectAcl",
			"s3:GetObjectTagging",
			"s3:GetObjectTorrent",
			"s3:GetObjectVersion",
			"s3:GetObjectVersionAcl",
			"s3:GetObjectVersionTagging",
			"s3:GetObjectVersionTorrent",
			"s3:ListMultipartUploadParts",
			"s3:PutObject",
			"s3:PutObjectAcl",
			"s3:PutObjectTagging",
			"s3:PutObjectVersionAcl",
			"s3:PutObjectVersionTagging",
			"s3:RestoreObject"
		]
		resources = [
			"arn:aws:s3:::${aws_s3_bucket.origin.id}/",
			"arn:aws:s3:::${aws_s3_bucket.origin.id}/*"
		]
		sid       = "ManageBucketObjects"
	}

	statement = {
		actions   = [
			"cloudfront:CreateInvalidation"
	  ]

		resources = [
		# Cloudfront doesn't allow resource-level permissions,
		# thus this allows invalidations on all distributions.
      "*"
		]
		sid       = "CreateCloudfrontInvalidation"
	}
}

resource "aws_iam_policy" "manage" {
	name = "${var.distribution_name}-manage"
	policy = "${data.aws_iam_policy_document.manage.json}"
}
