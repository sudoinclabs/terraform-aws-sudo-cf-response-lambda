# access data from current provider
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  code_path = var.lambda_code_path != "" ? "${path.root}/${var.lambda_code_path}" : "${path.module}/code"
}
# create public SNS topic: will trigger the lambda function
resource "aws_sns_topic" "cf_backed_sns" {
  name = "cf_backed_sns"
}

# policy: only the owner of the topic can subscribe to the topic and anybody can publish
resource "aws_sns_topic_policy" "cf_backed_sns" {
  arn    = aws_sns_topic.cf_backed_sns.arn
  policy = data.aws_iam_policy_document.cf_backed_sns.json
}

data "aws_iam_policy_document" "cf_backed_sns" {
  policy_id = "__default_policy_ID"
  statement {
    actions = [
      "SNS:Publish",
      "SNS:RemovePermission",
      "SNS:SetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:Receive",
      "SNS:AddPermission",
      "SNS:Subscribe"
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_sns_topic.cf_backed_sns.arn,
    ]
    sid = "__default_statement_ID"
  }
  statement {
    actions = [
      "SNS:Publish",
    ]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_sns_topic.cf_backed_sns.arn,
    ]
    sid = "__console_pub_0"
  }
}

# create IAM role for lambda custom function
resource "aws_iam_role" "send_cf_updates" {
  name               = "role_send_cf_updates-${data.aws_region.current.name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# create zip file for code directory
data "archive_file" "init" {
  type        = "zip"
  source_dir  = local.code_path
  output_path = "${local.code_path}.zip"
}

# create lambda function
resource "aws_lambda_function" "send_cf_updates" {
  function_name    = "send_cf_updates"
  filename         = data.archive_file.init.output_path
  role             = aws_iam_role.send_cf_updates.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256(data.archive_file.init.output_path)
  timeout          = var.timeout
  environment {
    variables = var.lambda_env_vars
  }
}

# gives cf_backed_sns permission to access the send_cf_updates Lambda function.
resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send_cf_updates.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.cf_backed_sns.arn
}

# create subscription for lambda to trigger on cf_backed_sns
resource "aws_sns_topic_subscription" "cf_backed_sns_to_send_cf_updates" {
  endpoint             = aws_lambda_function.send_cf_updates.arn
  protocol             = "lambda"
  raw_message_delivery = false
  topic_arn            = aws_sns_topic.cf_backed_sns.arn
}

resource "aws_iam_role_policy_attachment" "iam_corp_role_ssmread_policy_attachment" {
  role       = aws_iam_role.send_cf_updates.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
