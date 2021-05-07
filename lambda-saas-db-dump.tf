locals {
  provision_lambda_count = length(var.lambda-saas-db-dump-rsa-pubkey) > 0 && length(var.saas_db_dump_s3_destination_bucket) > 0 ? 1 : 0
  lambda-saas-db-dump-rsa-pubkey = replace(trimspace(var.lambda-saas-db-dump-rsa-pubkey), "/\r?\n/", "\\n")
}

data "archive_file" "lambda-saas-db-dump-zip-file" {
  type        = "zip"
  source_dir = "${path.module}/lambda-saas-db-dump/src"
  output_path = "${path.module}/lambda-saas-db-dump.zip"
}

resource "aws_iam_role" "iam-for-saas-db-dump-lambda" {
  count = local.provision_lambda_count

  name = "${var.name_prefix}-saas-db-dump-lambda-role"
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

resource "aws_iam_role_policy" "iam-policy-for-saas-db-dump-lambda" {
  count = local.provision_lambda_count

  name = "${var.name_prefix}-saas-db-dump-lambda-role-policy"
  role = aws_iam_role.iam-for-saas-db-dump-lambda[0].id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "rds-db:connect"
            ],
            "Resource": [
                "arn:aws:rds-db:${var.region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.scdb.resource_id}/scadmin_iam"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
              "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.lambda-saas-db-dump[0].name}:*",
              "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.lambda-saas-db-dump[0].name}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface"
            ],
            "Resource": "*"
        },
        {
            "Action": [
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::${var.saas_db_dump_s3_destination_bucket}"
        },
        {
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::${var.saas_db_dump_s3_destination_bucket}/${var.saas_db_dump_s3_destination_prefix}/*"
        }
    ]
}
EOF
}

resource "aws_cloudwatch_log_group" "lambda-saas-db-dump" {
  count = local.provision_lambda_count

  name              = "/aws/lambda/${var.name_prefix}-lambda-saas-db-dump"
  retention_in_days = 30

  tags = local.common_tags
}

resource "aws_lambda_function" "lambda-saas-db-dump" {
  count = local.provision_lambda_count

  function_name = "${var.name_prefix}-lambda-saas-db-dump"
  filename = data.archive_file.lambda-saas-db-dump-zip-file.output_path
  handler = "lambda_function.lambda_handler"
  role = aws_iam_role.iam-for-saas-db-dump-lambda[0].arn
  timeout = 900
  source_code_hash = data.archive_file.lambda-saas-db-dump-zip-file.output_base64sha256

  environment {
    variables = {
      DB_HOST = aws_db_instance.scdb.address
      DB_USERNAME = "scadmin_iam"
      S3_DESTINATION_BUCKET = var.saas_db_dump_s3_destination_bucket
      S3_DESTINATION_PREFIX = var.saas_db_dump_s3_destination_prefix
    }
  }

  runtime = "python3.7"

  vpc_config {
    subnet_ids = [
      aws_subnet.private_0.id,
      aws_subnet.private_1.id
    ]
    security_group_ids = [
      aws_security_group.mumbai-lambda-saas-db-dump-sg.id
    ]
  }
  depends_on = [
    aws_cloudwatch_log_group.lambda-saas-db-dump,
    aws_iam_role_policy.iam-policy-for-saas-db-dump-lambda
  ]

  tags = local.common_tags
}

resource "aws_cloudwatch_event_rule" "lambda-saas-db-dump" {
  count = local.provision_lambda_count

  name        = "${var.name_prefix}-lambda-saas-db-dump"
  description = "Encrypted DB export schedule rule"

  schedule_expression = var.lambda-saas-db-dump-cron-expression
}

resource "aws_cloudwatch_event_target" "lambda-saas-db-dump" {
  count = local.provision_lambda_count

  rule      = aws_cloudwatch_event_rule.lambda-saas-db-dump[0].name
  arn       = aws_lambda_function.lambda-saas-db-dump[0].arn
  input = <<JSON
{
  "pubkey" : "${local.lambda-saas-db-dump-rsa-pubkey}"
}
JSON
}
