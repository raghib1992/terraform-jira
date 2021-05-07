resource "aws_kms_key" "rds-key" {
  description = "${var.name_prefix} RDS key"
  enable_key_rotation = true
  policy = <<POLICY
{
    "Id": "key-consolepolicy-3",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::925201460575:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::925201460575:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::925201460575:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ]
}
POLICY

  tags = local.common_tags
  lifecycle {
      prevent_destroy = true
  }

}

resource "aws_kms_alias" "rds-key-alias" {
  name          = "alias/${var.name_prefix}-rds-key"
  target_key_id = aws_kms_key.rds-key.key_id
}


