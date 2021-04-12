data "aws_caller_identity" "current" {
}

data "aws_region" "current" {
}

data "aws_iam_policy_document" "allow_decrypt" {
  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
    ]

    resources = [var.datadog_kms_key_arn]
  }
}

data "archive_file" "lambda_code" {
  type        = "zip"
  source_file = "${path.module}/script/lambda_function.py"
  output_path = "${path.module}/.terraform/generated/lambda_function.zip"
}

