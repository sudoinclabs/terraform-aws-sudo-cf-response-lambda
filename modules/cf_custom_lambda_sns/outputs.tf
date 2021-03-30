output "lambda_arn" {
  value       = aws_lambda_function.handle_changes.arn
  description = "Use this ARN for Lambda backed CloudFormation Custom Resource."
}

output "sns_topic_arn" {
  value       = aws_sns_topic.cf_updates.arn
  description = "Use this ARN for SNS backed CloudFormation Custom Resource."
}