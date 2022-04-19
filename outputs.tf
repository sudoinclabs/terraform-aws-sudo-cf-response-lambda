output "cf_backed_sns_arn" {
  value       = aws_sns_topic.cf_backed_sns.arn
  description = "Arn of the SNS backed CloudFormation custom resource"
}

output "cf_backed_lambda_role_name" {
  value       = aws_iam_role.send_cf_updates.name
  description = "Role name of the lambda function"
}

output "cf_backed_lambda_arn" {
  value       = aws_lambda_function.send_cf_updates.arn
  description = "Arn of the lambda function"
}
