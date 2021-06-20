# output the sns arn for use in cloudformation template/consle
output "cf_backed_sns_arn" {
  value       = aws_sns_topic.cf_backed_sns.arn
  description = "Use this ARN for SNS backed CloudFormation Custom Resource."
}