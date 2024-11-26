# # ---------------------------------------------------------------------------------------------------------------------
# # SNS TOPIC
# # ---------------------------------------------------------------------------------------------------------------------

# resource "aws_sns_topic" "sns_topics" {
#   for_each = var.topics

#   name = each.key
#   tags = var.tags
# }


# # ---------------------------------------------------------------------------------------------------------------------
# # SQS QUEUE
# # ---------------------------------------------------------------------------------------------------------------------

# resource "aws_sqs_queue" "sqs_queues" {
#   for_each = var.queues

#   name = each.value.name
#   # redrive_policy             = each.value.redrive_policy
#   # visibility_timeout_seconds = each.value.visibility_timeout_seconds
#   tags = var.tags
# }


# # ---------------------------------------------------------------------------------------------------------------------
# # SQS POLICY
# # ---------------------------------------------------------------------------------------------------------------------
# resource "aws_sqs_queue_policy" "sqs_policies" {
#   for_each = var.queues

#   queue_url = aws_sqs_queue.sqs_queues[each.key].id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect    = "Allow",
#         Principal = "*",
#         Action    = "SQS:SendMessage",
#         Resource  = aws_sqs_queue.sqs_queues[each.key].arn,
#         Condition = {
#           ArnEquals = {
#             "aws:SourceArn" = aws_sns_topic.sns_topics[each.value.topic].arn
#           }
#         }
#       }
#     ]
#   })
# }


# # ---------------------------------------------------------------------------------------------------------------------
# # SNS SUBSCRIPTION
# # ---------------------------------------------------------------------------------------------------------------------
# resource "aws_sns_topic_subscription" "sns_subscriptions" {
#   for_each = var.queues

#   topic_arn            = aws_sns_topic.sns_topics[each.value.topic].arn
#   protocol             = "sqs"
#   endpoint             = aws_sqs_queue.sqs_queues[each.key].arn
#   raw_message_delivery = each.value.raw_message_delivery

#   filter_policy = each.value.filter_policy != false ? jsonencode({
#     scope = [
#       {
#         "anything-but" = ["SEND_TO_EXT"]
#       },
#       {
#         "exists" = false
#       }
#     ]
#   }) : null
# }


# # ---------------------------------------------------------------------------------------------------------------------
# # LAMBDA ROLE & POLICIES
# # ---------------------------------------------------------------------------------------------------------------------

# resource "aws_iam_role" "lambda_role" {
#   name = "LambdaRole"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy" "lambda_role_logs_policy" {
#   name = "LambdaRolePolicy"
#   role = aws_iam_role.lambda_role.id
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ],
#         Effect   = "Allow",
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy" "lambda_role_sqs_policy" {
#   name = "AllowSQSPermissions"
#   role = aws_iam_role.lambda_role.id
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = [
#           "sqs:ChangeMessageVisibility",
#           "sqs:DeleteMessage",
#           "sqs:GetQueueAttributes",
#           "sqs:ReceiveMessage"
#         ],
#         Effect   = "Allow",
#         Resource = "*"
#       }
#     ]
#   })
# }


# ---------------------------------------------------------------------------------------------------------------------
# LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function" "lambda_func" {

  filename      = "${path.module}/lambda/example.zip"
  function_name = var.lambda.name
  # role             = aws_iam_role.lambda_role.arn
  role             = var.lambda.role
  handler          = var.lambda.handler
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = var.lambda.runtime
  tags             = var.tags

  environment {
    variables = {
      foo = "bar"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# LAMBDA EVENT SOURCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_event_source_mapping" "lambda_func_event_source" {
  # event_source_arn = aws_sqs_queue.sqs_queues["queue-1"].arn
  event_source_arn = var.lambda.queue
  enabled          = true
  function_name    = aws_lambda_function.lambda_func.arn
  batch_size       = 1
}
