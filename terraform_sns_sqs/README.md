# Terraform SNS a SQS a Lambda

A continuación se muestra un tutorial de infraestructura como código de AWS con Terraform.

## Arquitectura

SNS --> SQS --> LAMBDA

## Descripción

El código crea tres recursos:

1) Un tema de redes sociales
2) Una cola SQS que se suscribe al tema SNS
3) Una función Lambda que se suscribe a la cola SQS
