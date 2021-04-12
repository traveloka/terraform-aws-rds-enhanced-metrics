variable "environment" {
  type        = string
  description = "The environment this Lambda function belongs to"
}

variable "service_name" {
  type        = string
  description = "The name of the service which owns this Lambda function"
}

variable "product_domain" {
  type        = string
  description = "The product domain which owns this Lambda function"
}

variable "description" {
  type        = string
  description = "The description to be put on Lambda function tag"
}

variable "datadog_kms_key_arn" {
  type        = string
  description = "The ARN of KMS key used to encrypt/decrypt Datadog keys"
}

variable "kms_encrypted_keys" {
  type        = string
  description = "The encrypted Datadog API key and Datadog application key. Go through README for details"
}

variable "retention_in_days" {
  type        = string
  description = "Specifies the number of days you want to retain lambda function log"
  default     = "14"
}