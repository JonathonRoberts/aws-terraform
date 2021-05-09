data "aws_iam_policy_document" "s3_readonly" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets"
    ]

    resources = [
      "arn:aws:s3:::tfiam"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::tfiam/*"
    ]
  }
}
resource "aws_iam_policy" "tf_s3_readonly" {
  name        = "TerraformS3Readonly"
  description = "Terraform S3 readonly access."
  policy      = data.aws_iam_policy_document.s3_readonly.json
}
data "aws_iam_policy_document" "ec2_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "s3_role" {
  name = "S3Role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  tags = {
    name = "S3Role"
  }
}
resource "aws_iam_role_policy_attachment" "tf_attach" {
  role       = aws_iam_role.s3_role.name
  policy_arn = aws_iam_policy.tf_s3_readonly.arn
}
