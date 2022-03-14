# output the sns arn for use in cloudformation template/consle
output "cf_backed_sns_arn" {
  value       = aws_sns_topic.cf_backed_sns.arn
  description = "Use this ARN for SNS backed CloudFormation Custom Resource."
}



output "cf_backed_lambda_role_name" {
  value       = aws_iam_role.send_cf_updates.name
  description = "Use this Role Name for to add policies to your lambda."
}
