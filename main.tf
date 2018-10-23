module "datadog_lambda_role" {
  source = "github.com/traveloka/terraform-aws-iam-role//modules/lambda?ref=v0.6.0"

  product_domain   = "${var.product_domain}"
  service_name     = "${var.service_name}"
  descriptive_name = "RDS enhanced metrics integration to Datadog"
}

resource "aws_iam_role_policy" "allow_decrypt_using_kms" {
  role   = "${module.datadog_lambda_role.role_name}"
  policy = "${data.aws_iam_policy_document.allow_decrypt.json}"
}

resource "aws_iam_role_policy_attachment" "datadog_lambda_basic_execution" {
  role       = "${module.datadog_lambda_role.role_name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

module "lambda_function_name" {
  source = "github.com/traveloka/terraform-aws-resource-naming?ref=v0.7.1"

  name_prefix   = "${var.product_domain}-send-enhanced-rds-to-datadog"
  resource_type = "lambda_function"
}

resource "aws_lambda_function" "send_enhanced_rds_to_datadog" {
  function_name    = "${module.lambda_function_name.name}"
  role             = "${module.datadog_lambda_role.role_arn}"
  filename         = ".terraform/generated/lambda_function.zip"
  source_code_hash = "${base64sha256(file(".terraform/generated/lambda_function.zip"))}"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python2.7"
  memory_size      = 128
  timeout          = 10

  environment {
    variables = {
      kmsEncryptedKeys = "${var.kms_encrypted_keys}"
    }
  }

  tags {
    Name          = "${module.lambda_function_name.name}"
    Service       = "${var.service_name}"
    ProductDomain = "${var.product_domain}"
    Environment   = "${var.environment}"
    Description   = "${var.description}"
    ManagedBy     = "Terraform"
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id   = "AllowExecutionFromCloudWatch"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.send_enhanced_rds_to_datadog.function_name}"
  principal      = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_account = "${data.aws_caller_identity.current.account_id}"
  source_arn     = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:RDSOSMetrics:*"
}

resource "aws_cloudwatch_log_subscription_filter" "logfilter" {
  name            = "${var.service_name}_rdsDatadogIntegration_logfilter"
  log_group_name  = "RDSOSMetrics"
  filter_pattern  = ""
  destination_arn = "${aws_lambda_function.send_enhanced_rds_to_datadog.arn}"
}
