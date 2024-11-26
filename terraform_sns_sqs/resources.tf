# Crear tópicos SNS
resource "aws_sns_topic" "sns_topics" {
  for_each = var.topics

  name = each.key
  tags = var.tags
}

# Crear colas SQS
resource "aws_sqs_queue" "sqs_queues" {
  for_each = var.queues

  name = each.value.name
  # redrive_policy             = each.value.redrive_policy
  # visibility_timeout_seconds = each.value.visibility_timeout_seconds
  tags = var.tags
}

# Crear suscripciones SNS
resource "aws_sns_topic_subscription" "sns_subscriptions" {
  for_each = var.queues

  topic_arn            = aws_sns_topic.sns_topics[each.value.topic].arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.sqs_queues[each.key].arn
  raw_message_delivery = each.value.raw_message_delivery

  filter_policy = each.value.filter_policy != false ? jsonencode({
    scope = [
      {
        "anything-but" = ["SEND_TO_EXT"]
      },
      {
        "exists" = false
      }
    ]
  }) : null
}

# Crear políticas de SQS para permitir el envío de mensajes desde SNS
resource "aws_sqs_queue_policy" "sqs_policies" {
  for_each = var.queues

  queue_url = aws_sqs_queue.sqs_queues[each.key].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "SQS:SendMessage",
        Resource  = aws_sqs_queue.sqs_queues[each.key].arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.sns_topics[each.value.topic].arn
          }
        }
      }
    ]
  })
}

# # 2. Crear múltiples tópicos de SNS de acuerdo con la configuración en la variable
# resource "aws_sns_topic" "sns_topics" {
#   for_each = var.sns_sqs_config
#   name     = each.key
# }

# # 3. Crear múltiples colas de SQS
# resource "aws_sqs_queue" "sqs_queues" {

#   for_each = { 
#     for topic_name, config in var.sns_sqs_config : topic_name => config
#   }
#   # for_each = 
#   name = each.value
# }

# 4. Crear suscripciones entre tópicos y colas (similar a bucles anidados)
# resource "aws_sns_topic_subscription" "sns_subscriptions" {
#   for_each = { 
#     for topic_name, config in var.sns_sqs_config : 
#     for queue_name in config.queues : 
#     "${topic_name}_${queue_name}" => {
#       topic_arn = aws_sns_topic.sns_topics[topic_name].arn
#       queue_arn = aws_sqs_queue.sqs_queues["${topic_name}_${queue_name}"].arn
#     }
#   }

#   topic_arn           = each.value.topic_arn
#   protocol            = "sqs"
#   endpoint            = each.value.queue_arn
#   raw_message_delivery = true

#   filter_policy = jsonencode({
#     scope = [
#       {
#         "anything-but" = ["SEND_TO_EXT"]
#       },
#       {
#         "exists" = false
#       }
#     ]
#   })
# }

# 

# 3. Crear múltiples colas de SQS de acuerdo con la configuración en la variable
# resource "aws_sqs_queue" "sqs_queues" {
#   for_each = toset(flatten([
#     for topic_name, config in var.sns_sqs_config :
#     [for queue_name in config.queues : "${topic_name}_${queue_name}"]
#   ]))
#   name = each.value
# }

# # 4. Crear suscripciones entre tópicos y colas, habilitando "raw_message_delivery" y aplicando el filtro
# resource "aws_sns_topic_subscription" "sns_subscriptions" {
#   for_each             = { for topic_name, config in var.sns_sqs_config : topic_name => config }
#   topic_arn            = aws_sns_topic.sns_topics[each.key].arn
#   protocol             = "sqs"
#   endpoint             = aws_sqs_queue.sqs_queues["${each.key}_${each.value}"].arn
#   raw_message_delivery = true

#   filter_policy = jsonencode({
#     scope = [
#       {
#         "anything-but" = ["SEND_TO_EXT"]
#       },
#       {
#         "exists" = false
#       }
#     ]
#   })
# }

# # 5. Política de permisos de SQS para permitir que SNS envíe mensajes a las colas correspondientes
# resource "aws_sqs_queue_policy" "sqs_policies" {
#   for_each = aws_sqs_queue.sqs_queues

#   queue_url = each.value.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = "*",
#         Action = "SQS:SendMessage",
#         Resource = each.value.arn,
#         Condition = {
#           ArnEquals = {
#             "aws:SourceArn" = aws_sns_topic.sns_topics[each.key].arn
#           }
#         }
#       }
#     ]
#   })
# }

# resource "null_resource" "log_topics" {
#   # Usando count: Entrega un índice
#   # count = length(var.test_list)
#   # provisioner "local-exec" {
#   #   command = "echo Index:${count.index} -> Value:${var.test_list[count.index]}"
#   # }

#   # # Usando for_each: Requiere un conjunto (set, map)
#   # for_each = toset(var.test_list)
#   # provisioner "local-exec" {
#   #   command = "echo Value:${each.value}"
#   # }

#   # Usando for para crear un conjunto: Crear un map/set a partir de una lista con for
#   for_each = { for list_val in var.test_list : list_val => list_val }
#   provisioner "local-exec" {
#     command = "echo Index ${each.key} -> Value: ${jsonencode(each.value)}"
#   }
# }

# # Crear tópicos SNS
# resource "aws_sns_topic" "sns_topics" {
#   for_each = { for topic in var.topics : topic.name => topic }

#   name = each.key
#   tags = var.tags
# }

# # Crear colas SQS
# resource "aws_sqs_queue" "sqs_queues" {
#   for_each = flatten([
#     for topic in var.topics : 
#     [  for queue in topic.queues : "${queue.name}" => queue]
#   ])
#   name = each.value
# }

# # Crear suscripciones SNS
# resource "aws_sns_topic_subscription" "sns_subscriptions" {
#   for_each = { for topic in var.topics :
#     topic.name => { for queue in topic.queues : "${topic.name}-${queue.name}" => queue }
#   }

#   topic_arn            = aws_sns_topic.sns_topics[each.value.topic_name].arn
#   protocol             = "sqs"
#   endpoint             = aws_sqs_queue.sqs_queues[each.key].arn
#   raw_message_delivery = each.value.raw_message_delivery

#   filter_policy = each.value.filter_policy != null ? jsonencode(each.value.filter_policy) : null
# }

# # Crear políticas de SQS para permitir el envío de mensajes desde SNS
# resource "aws_sqs_queue_policy" "sqs_policies" {
#   for_each = { for topic in var.topics :
#     topic.name => { for queue in topic.queues : "${topic.name}-${queue.name}" => queue }
#   }

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
#             "aws:SourceArn" = aws_sns_topic.sns_topics[each.value.topic_name].arn
#           }
#         }
#       }
#     ]
#   })
# }
# ---------------------------------------------------------------------------------------------------------------------
# SNS TOPIC
# ---------------------------------------------------------------------------------------------------------------------

# resource "aws_sns_topic" "results_updates" {
#   name = "results-updates-topic"

#   tags = {
#     Administradopor  = "Manual"
#     Analista         = "Sebastian Gomez"
#     Aprobadopor      = "Didier Correa"
#     BackupPolicy     = "No Aplica"
#     CentrodeCostos   = "CO02VO0268"
#     Creadopor        = "Sebastian Gomez"
#     GrupodeServicios = "TRANSVERSALES DE TECNOLOGIA Y MULTINUBE"
#     Proyecto         = "Arq-ref-python"
#   }
# }




# ---------------------------------------------------------------------------------------------------------------------
# SQS QUEUE
# ---------------------------------------------------------------------------------------------------------------------

# resource "aws_sqs_queue" "results_updates_queue" {
#   name                       = "results-updates-queue"
#   redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.results_updates_dl_queue.arn}\",\"maxReceiveCount\":5}"
#   visibility_timeout_seconds = 300

#   tags = {
#     Environment = "dev"
#   }
# }


# resource "aws_sqs_queue" "results_updates_dl_queue" {
#   name = "results-updates-dl-queue"
# }



# ---------------------------------------------------------------------------------------------------------------------
# SQS POLICY
# ---------------------------------------------------------------------------------------------------------------------
# resource "aws_sqs_queue_policy" "sqs_policy" {
#   queue_url = aws_sqs_queue.results_updates_queue.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect    = "Allow",
#         Principal = "*",
#         Action    = "SQS:SendMessage",
#         Resource  = "${aws_sqs_queue.results_updates_queue.arn}",
#         Condition = {
#           ArnEquals = {
#             "aws:SourceArn" = "${aws_sns_topic.results_updates.arn}"
#           }
#         }
#       }
#     ]
#   })
# }



# ---------------------------------------------------------------------------------------------------------------------
# SNS SUBSCRIPTION
# ---------------------------------------------------------------------------------------------------------------------
# resource "aws_sns_topic_subscription" "results_updates_sqs_target" {
#   topic_arn            = aws_sns_topic.results_updates.arn
#   protocol             = "sqs"
#   endpoint             = aws_sqs_queue.results_updates_queue.arn
#   raw_message_delivery = true

#   filter_policy = jsonencode({
#     scope = [
#       {
#         "anything-but" = ["SEND_TO_EXT"]
#       },
#       {
#         "exists" = false
#       }
#     ]
#   })
# }


# # ---------------------------------------------------------------------------------------------------------------------
# # LAMBDA ROLE & POLICIES
# # ---------------------------------------------------------------------------------------------------------------------

# resource "aws_iam_role" "lambda_role" {
#   name               = "LambdaRole"
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#         "Action": "sts:AssumeRole",
#         "Effect": "Allow",
#         "Principal": {
#             "Service": "lambda.amazonaws.com"
#         }
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy" "lambda_role_logs_policy" {
#   name   = "LambdaRolePolicy"
#   role   = aws_iam_role.lambda_role.id
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ],
#       "Effect": "Allow",
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy" "lambda_role_sqs_policy" {
#   name   = "AllowSQSPermissions"
#   role   = aws_iam_role.lambda_role.id
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "sqs:ChangeMessageVisibility",
#         "sqs:DeleteMessage",
#         "sqs:GetQueueAttributes",
#         "sqs:ReceiveMessage"
#       ],
#       "Effect": "Allow",
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }

# # ---------------------------------------------------------------------------------------------------------------------
# # LAMBDA FUNCTION
# # ---------------------------------------------------------------------------------------------------------------------

# resource "aws_lambda_function" "results_updates_lambda" {
#   filename         = "${path.module}/lambda/example.zip"
#   function_name    = "hello_world_example"
#   role             = aws_iam_role.lambda_role.arn
#   handler          = "example.handler"
#   source_code_hash = data.archive_file.lambda_zip.output_base64sha256
#   runtime          = "nodejs12.x"

#   environment {
#     variables = {
#       foo = "bar"
#     }
#   }
# }

# # ---------------------------------------------------------------------------------------------------------------------
# # LAMBDA EVENT SOURCE
# # ---------------------------------------------------------------------------------------------------------------------

# resource "aws_lambda_event_source_mapping" "results_updates_lambda_event_source" {
#   event_source_arn = aws_sqs_queue.results_updates_queue.arn
#   enabled          = true
#   function_name    = aws_lambda_function.results_updates_lambda.arn
#   batch_size       = 1
# }
