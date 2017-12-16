variable "name" {}

output "arn" { value = "${aws_iam_role.iam_for_lambda.arn}" }

resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
    role       = "${aws_iam_role.iam_for_lambda.name}"
    policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.name}Policy"
  description = "Grant basic permissions."
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "dynamodb:GetItem"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
