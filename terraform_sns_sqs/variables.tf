# ---------------------------------------------------------------------------------------------------------------------
# VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "region" {
  description = "The name of the region"
  type        = string
  sensitive   = false
}

variable "access_key" {
  description = "The access key for AWS"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "The secret key for AWS"
  type        = string
  sensitive   = true
}
variable "tags" {
  type = map(string)
}

variable "topics" {
  type = set(string)
}

variable "queues" {
  type = map(object({
    name                 = string
    raw_message_delivery = bool
    filter_policy        = bool
    topic                = string
  }))
}

variable "lambda" {
  type = object({
    name    = string
    handler = string
    runtime = string
    role    = string
    queue   = string
  })
  default = {
    name    = "terraform-lambda-example"
    handler = "example.handler"
    runtime = "nodejs18.x"
    role    = "arn:aws:iam::036796669465:role/iam-role-ssm-proteccion-remediation-dev"
    queue   = "arn:aws:sqs:us-east-1:036796669465:q-test-splunk-arqRef"
  }

}
