output "lambda_arn" {
  value       = module.cf_custom_lambda_sns.lambda_arn
  description = "Use this ARN for Lambda backed CloudFormation Custom Resource."
}

output "sns_topic_arn" {
  value       = module.cf_custom_lambda_sns.sns_topic_arn
  description = "Use this ARN for SNS backed CloudFormation Custom Resource."
}