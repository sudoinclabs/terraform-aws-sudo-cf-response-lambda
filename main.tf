# access data from current provider
data "aws_caller_identity" "current" {}

# Create public SNS topic
resource "aws_sns_topic" "cf_backed_sns" {
  name = "cf_backed_sns"
}

#Policy: Only the owner of the topic can subscribe to the topic and Anybody can publish
resource "aws_sns_topic_policy" "cf_backed_sns" {
  arn = aws_sns_topic.cf_backed_sns.arn
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

# Create a SNS topic for internal email
resource "aws_sns_topic" "lambda_email_sns" {
  name = "lambda_email_sns"
}

# Send Email to suscribe email to lambda_email_sns topic
module "sns-email-subscription" {
  source  = "QuiNovas/sns-email-subscription/aws"
  version = "0.0.3"
  email_address = var.email_address
  topic_arn = aws_sns_topic.lambda_email_sns.arn
}

# Create IAM Role for Lambda Custom Function
resource "aws_iam_role" "send_cf_updates" {
  name = "role_send_cf_updates"
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

# Create zip file for code directory
data "archive_file" "init" {
  type = "zip"
  source_dir = "${path.module}/code"
  output_path = "${path.module}/code.zip"
}

# Create Lambda function
resource "aws_lambda_function" "send_cf_updates" {
  function_name = "send_cf_updates"
  filename      = data.archive_file.init.output_path
  role          = aws_iam_role.send_cf_updates.arn
  handler       = "lambda_function.lambda_handler"
  runtime = "python3.8"
  # runtime = "nodejs12.x"

  source_code_hash = filebase64sha256(data.archive_file.init.output_path)

  # Send SNS topic ARN as ENV
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.lambda_email_sns.arn
    }
  }

  depends_on = [
    aws_sns_topic.lambda_email_sns
  ]
}

# Gives cf_backed_sns permission to access the send_cf_updates Lambda function.
resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send_cf_updates.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.cf_backed_sns.arn
}

# Create subscription for lambda to trigger on cf_backed_sns
resource "aws_sns_topic_subscription" "cf_backed_sns_to_send_cf_updates" {
  endpoint = aws_lambda_function.send_cf_updates.arn
  protocol = "lambda"
  raw_message_delivery = false
  topic_arn = aws_sns_topic.cf_backed_sns.arn
}

# Permission policy for send_cf_updates to use lambda_email_sns
data "aws_iam_policy_document" "lambda_email_sns" {
  statement {
    sid = ""
    actions = [
      "sns:ListSubscriptionsByTopic",
      "sns:Publish",
      "sns:Subscribe"
    ]
    resources = [
      aws_sns_topic.lambda_email_sns.arn,
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "lambda_email_sns" {
  name   = "lambda_email_sns"
  description = "Allow SNS limited access"
  policy = data.aws_iam_policy_document.lambda_email_sns.json
}

resource "aws_iam_role_policy_attachment" "send_cf_updates_lambda_email_sns" {
  role       = aws_iam_role.send_cf_updates.name
  policy_arn = aws_iam_policy.lambda_email_sns.arn
}



# FOR TESTING: Invoke Lambda, Destination SNS
/*
resource "aws_lambda_function_event_invoke_config" "testing" {
  function_name = aws_lambda_function.send_cf_updates.function_name
  destination_config {
    on_failure {
      destination = aws_sns_topic.lambda_email_sns.arn
    }
    on_success {
      destination = aws_sns_topic.lambda_email_sns.arn
    }
  }
  depends_on = [
    aws_sns_topic.lambda_email_sns,
    aws_lambda_function.send_cf_updates
  ]
}
*/
