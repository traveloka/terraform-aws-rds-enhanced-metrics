module "datadog_lambda_role" {
  source = "github.com/traveloka/terraform-aws-iam-role//modules/lambda?ref=v2.0.2"
  product_domain   = var.product_domain
  service_name     = var.service_name
  environment = var.environment
  descriptive_name = local.role_descriptive_name
}

resource "aws_iam_role_policy" "allow_decrypt_using_kms" {
  role   = module.datadog_lambda_role.role_name
  policy = data.aws_iam_policy_document.allow_decrypt.json
}

resource "aws_iam_role_policy_attachment" "datadog_lambda_basic_execution" {
  role       = module.datadog_lambda_role.role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

module "lambda_function_name" {
  source = "github.com/traveloka/terraform-aws-resource-naming?ref=v0.19.1"

  name_prefix   = "${var.service_name}-${local.role_descriptive_name}"
  resource_type = "lambda_function"
}

resource "aws_lambda_function" "send_rds_enhanced_to_datadog" {
  function_name    = module.lambda_function_name.name
  role             = module.datadog_lambda_role.role_arn
  filename         = data.archive_file.lambda_code.output_path
  source_code_hash = data.archive_file.lambda_code.output_base64sha256
  handler          = local.lambda_handler
  runtime          = local.lambda_runtime
  memory_size      = local.lambda_memory_size
  timeout          = local.lambda_timeout

  environment {
    variables = {
      kmsEncryptedKeys = var.kms_encrypted_keys
    }
  }

  tags = {
    Name          = module.lambda_function_name.name
    Service       = var.service_name
    ProductDomain = var.product_domain
    Environment   = var.environment
    Description   = var.description
    ManagedBy     = "terraform"
  }
}

resource "aws_cloudwatch_log_group" "lambda_function-send_rds_enhanced_metrics" {
  name              = "/aws/lambda/${aws_lambda_function.send_rds_enhanced_to_datadog.function_name}"
  retention_in_days = var.retention_in_days
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id   = "AllowExecutionFromCloudWatch"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.send_rds_enhanced_to_datadog.function_name
  principal      = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
  source_arn     = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:RDSOSMetrics:*"
}

resource "aws_cloudwatch_log_subscription_filter" "logfilter" {
  name            = "${var.service_name}_rdsDatadogIntegration_logfilter"
  log_group_name  = "RDSOSMetrics"
  filter_pattern  = ""
  destination_arn = aws_lambda_function.send_rds_enhanced_to_datadog.arn
}

