locals {
  lambda_handler     = "lambda_function.lambda_handler"
  lambda_runtime     = "python3.8"
  lambda_memory_size = 128
  lambda_timeout     = 10

  role_descriptive_name = "send_rds_enhanced_metrics_datadog"
}

