locals {
  ses_smtp_from_address = "saas+${var.name_prefix}@securecircle.com"
}

resource "aws_iam_role" "ecs-service-role" {
    name                = "${var.name_prefix}-saas-ecs-service-role"
    path                = "/"
    assume_role_policy  = data.aws_iam_policy_document.ecs-service-policy.json
}

resource "aws_iam_role_policy_attachment" "ecs-service-role-attachment" {
    role       = aws_iam_role.ecs-service-role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs-service-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ecs.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "ecs-instance-role" {
    name                = "${var.name_prefix}-ecs-instance-role"
    path                = "/"
    assume_role_policy  = data.aws_iam_policy_document.ecs-instance-policy.json
}

resource "aws_iam_role_policy" "ecs-instance-asg-lifecycle-management-policy" {
  name = "ecs-instance-asg-lifecycle-management-policy"
  role = aws_iam_role.ecs-instance-role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "autoscaling:DescribeAutoScalingInstances",
                "ec2:DescribeAddresses",
                "ec2:AssociateAddress"
            ],
            "Resource": "*"
        },
        {
            "Sid": "sid3",
            "Effect": "Allow",
            "Action": [
                "autoscaling:CompleteLifecycleAction"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "autoscaling:ResourceTag/sc_customer": "${var.name_prefix}"
                }
            }
        }
    ]
}
EOF
}

#resource "aws_iam_role_policy" "ecs-instance-tg-registration-policy" {
#  name = "ecs-instance-tg-registration-policy"
#  role = "${aws_iam_role.ecs-instance-role.id}"
#
#  policy = <<EOF
#{
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Sid": "VisualEditor0",
#            "Effect": "Allow",
#            "Action": "elasticloadbalancing:RegisterTargets",
#            "Resource": [ "${aws_alb_target_group.ecs-scconverter.arn}", "${aws_lb_target_group.scconverter-target-group.arn}" ]
#        }
#    ]
#}
#EOF
#}

resource "aws_iam_role_policy_attachment" "ecs-instance-s3-attachment" {
    role       = aws_iam_role.ecs-instance-role.name
    policy_arn = "arn:aws:iam::925201460575:policy/sc-saas-client-s3-access"
}

resource "aws_iam_role_policy_attachment" "ecs-instance-s3-config-attachment" {
    role       = aws_iam_role.ecs-instance-role.name
    policy_arn = "arn:aws:iam::925201460575:policy/sc-saas-config-s3-access"
}

resource "aws_iam_role_policy_attachment" "ssm-role-attachment" {
    role       = aws_iam_role.ecs-instance-role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

data "aws_iam_policy_document" "ecs-instance-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
    role       = aws_iam_role.ecs-instance-role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
    name = "${var.name_prefix}-ecs-instance-profile"
    path = "/"
    role = aws_iam_role.ecs-instance-role.id
    provisioner "local-exec" {
      command = "sleep 10"
    }
}

resource "aws_iam_user" "ses-iam-user" {
    name = "ses-smtp-user-tf.${var.name_prefix}"
    path = "/ses-smtp-user-tf/"

}

resource "aws_iam_user_policy" "ses-iam-user-policy" {
  name = "allow-ses-smtp-policy"
  user = aws_iam_user.ses-iam-user.name

  policy = data.aws_iam_policy_document.ses-iam-user-policy.json
}

data "aws_iam_policy_document" "ses-iam-user-policy" {
  statement {
    effect = "Allow"
    actions = ["ses:SendRawEmail"]
    resources = ["*"]
    condition {
      test = "StringEquals"
      values = [local.ses_smtp_from_address]
      variable = "ses:FromAddress"
    }
    condition {
      test = "StringEquals"
      values = aws_eip.instance-eip[*].public_ip
      variable = "aws:SourceIp"
    }
  }
}

resource "aws_iam_access_key" "ses-iam-user-key" {
  user = aws_iam_user.ses-iam-user.name
}

output "ses-iam-user-from-address" {
  value = local.ses_smtp_from_address
}

output "ses-iam-user-smtp-username" {
  value = aws_iam_access_key.ses-iam-user-key.id
}

output "ses-iam-user-smtp-password" {
  value = aws_iam_access_key.ses-iam-user-key.ses_smtp_password
}
