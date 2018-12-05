resource "aws_iam_user" "ci" {
	count = "${var.create_ci_user ? 1 : 0}"
	name  = "${var.distribution_name}-ci"
}


resource "aws_iam_user_policy" "ci" {
	count = "${var.create_ci_user ? 1 : 0}"
  name  = "write_to_origin_and_invalidate_cloudfront"
  user  = "${aws_iam_user.ci.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.origin.id}/",
        "arn:aws:s3:::${aws_s3_bucket.origin.id}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
          "cloudfront:CreateInvalidation"
      ],
      "Resource": "${aws_cloudfront_distribution.distribution.arn}"
    }
  ]
}
EOF
}
