data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "allow_decrypt" {
  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
    ]

    resources = ["${var.datadog_kms_key_arn}"]
  }
}
