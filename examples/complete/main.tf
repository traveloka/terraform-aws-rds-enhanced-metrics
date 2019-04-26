provider "aws" {
  version = "1.33.0"
  region  = "ap-southeast-1"
}

module "rds_enhanced_metric_lambda" {
  source = "../.."

  environment         = "staging"
  service_name        = "<service_name>"
  product_domain      = "<product_domain>"
  description         = "Lambda function to send RDS enhanced metrics to Datadog"
  datadog_kms_key_arn = "arn:aws:kms:<region>:<account_id>:key/<key_id>"
  kms_encrypted_keys  = "<encrypted_datadog_keys>"
  retention_in_days   = "14"
}
