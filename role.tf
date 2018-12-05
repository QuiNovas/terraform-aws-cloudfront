resource "aws_iam_role" "ci" {
  name               = "${var.distribution_name}-ci"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "ci" {
  name   = "write_to_origin_and_invalidate_cloudfront"
  role   = "${aws_iam_role.ci.id}"
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
