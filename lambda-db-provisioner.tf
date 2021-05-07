data "archive_file" "lambda-db-provisioner-zip-file" {
  type        = "zip"
  source_dir = "${path.module}/lambda-db-provisioner/src"
  output_path = "${path.module}/lambda-db-provisioner.zip"
}

resource "aws_iam_role" "iam-for-db-provisioner-lambda" {
  name = "${var.name_prefix}-db-provisioner-lambda-role"
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

resource "aws_iam_role_policy" "iam_for_lambda" {
  name = "${var.name_prefix}-db-provisioner-lambda-role-policy"
  role = aws_iam_role.iam-for-db-provisioner-lambda.id

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource": [
            "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.lambda-db-provisioner.name}:*",
            "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.lambda-db-provisioner.name}"
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
      }
   ]
}
EOF
}

resource "aws_cloudwatch_log_group" "lambda-db-provisioner" {
  name              = "/aws/lambda/${var.name_prefix}-lambda-db-provisioner"
  retention_in_days = 30

  tags = local.common_tags
}

resource "aws_security_group" "mumbai-lambda-db-provisioner-sg" {
  name = "${var.name_prefix}-lambda-db-provisioner-sg"
  vpc_id = aws_vpc.mumbai-vpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

  tags = local.common_tags
}

resource "aws_lambda_function" "lambda-db-provisioner" {

  function_name = "${var.name_prefix}-lambda-db-provisioner"
  filename = data.archive_file.lambda-db-provisioner-zip-file.output_path
  handler = "lambda_db_provisioner.lambda_handler"
  role = aws_iam_role.iam-for-db-provisioner-lambda.arn

  source_code_hash = data.archive_file.lambda-db-provisioner-zip-file.output_base64sha256

  runtime = "python3.7"

  vpc_config {
    subnet_ids = [
      aws_subnet.private_0.id,
      aws_subnet.private_1.id
    ]
    security_group_ids = [
      aws_security_group.mumbai-lambda-db-provisioner-sg.id
    ]
  }
  depends_on = [
    aws_cloudwatch_log_group.lambda-db-provisioner,
    aws_iam_role_policy.iam_for_lambda
  ]

  tags = local.common_tags
}

data "aws_lambda_invocation" "lambda-db-provisioner" {
  function_name = aws_lambda_function.lambda-db-provisioner.function_name

  input = <<JSON
{
  "aws_region": "${var.region}",
  "db_host": "${aws_db_instance.scdb.address}",
  "db_username": "${local.username}",
  "db_password": "${local.plaintext_pw}",
  "create_username": "scadmin_iam",
  "use_aws_plugin": true,
  "create_dbs": [
    "System",
    "Tracker",
    "Runtime",
    "Logging",
    "Share",
    "Spare"
  ]
}
JSON
  depends_on = [aws_lambda_function.lambda-db-provisioner]
}

resource "null_resource" "lambda-db-provisioner" {
  triggers = {
    lambda-db-provisioner = data.aws_lambda_invocation.lambda-db-provisioner.result
  }

  depends_on = [aws_lambda_function.lambda-db-provisioner]
}
