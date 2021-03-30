# Create IAM Role for Lambda Custom Function
resource "aws_iam_role" "role_for_lambda" {
  name = "role_for_lambda"
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

# Permission policy for lambda to use SNS
resource "aws_iam_policy" "policy_for_sns" {
  name        = "policy_for_sns"
  description = "Allow SNS full access"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "sns:ListSubscriptionsByTopic",
                "sns:Publish",
                "sns:Subscribe"
            ],
            "Resource": "arn:aws:sns:*:*:cf_updates"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_lambda_role_sns_policy" {
  role       = aws_iam_role.role_for_lambda.name
  policy_arn = aws_iam_policy.policy_for_sns.arn
}

# Create zip file for code directory
data "archive_file" "init" {
  type = "zip"
  source_dir = "${path.module}/code"
  output_path = "${path.module}/code.zip"
}

# Create SNS topic
resource "aws_sns_topic" "cf_updates" {
  name = "cf_updates"
}

# Create Lambda function
resource "aws_lambda_function" "handle_changes" {
  function_name = "handle_changes"
  filename = data.archive_file.init.output_path
  role          = aws_iam_role.role_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  
  source_code_hash = filebase64sha256(data.archive_file.init.output_path)
  runtime = "python3.8"

  # Send SNS topic ARN as ENV
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.cf_updates.arn
    }
  }

  depends_on = [
    aws_sns_topic.cf_updates
  ]
}

# FOR TESTING: Invoke Lambda, Destination SNS
/*
resource "aws_lambda_function_event_invoke_config" "lambda_sns" {
  function_name = aws_lambda_function.handle_changes.function_name
  destination_config {
    on_failure {
      destination = aws_sns_topic.cf_updates.arn
    }
    on_success {
      destination = aws_sns_topic.cf_updates.arn
    }
  }
  depends_on = [
    aws_sns_topic.cf_updates,
    aws_lambda_function.handle_changes
  ]
}
*/