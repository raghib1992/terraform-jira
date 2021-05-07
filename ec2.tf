locals {
  hostname = substr(sha256("${var.name_prefix}:ponyo"),-10,-1)
}

output "hostname" {
  value = "${local.hostname}.${var.domainname}"
}

resource "aws_launch_template" "mumbai-ec2-lt" {
  name_prefix = "${var.name_prefix}-mumbai-ec2-lt-"
  image_id = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type
  #network_interfaces {
  #  associate_public_ip_address = true
  #}
  user_data = base64encode(data.template_file.ec2-userdata.rendered)
  vpc_security_group_ids = [ aws_security_group.mumbai-ec2-sg.id ]
  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs-instance-profile.arn
  }
  instance_initiated_shutdown_behavior = "terminate"

  credit_specification {
    cpu_credits = "standard"
  }

  tag_specifications {
      resource_type = "instance"
      tags = merge(
               local.common_tags,
               {
                 Name = "${var.name_prefix}-saas-member"
               }
      )
  }
  tags = local.common_tags
}

data "template_file" "ec2-userdata" {
  template = file("userdata.template")

  vars = {
    hostname = local.hostname
    domainname = var.domainname
    dbname = aws_db_instance.scdb.address
    dbport = "3306"
    plaintext-pw = local.plaintext_pw
    username = "scadmin"
    log-group = aws_cloudwatch_log_group.ecs-service-log-group.name
    region = var.region
    customer = var.name_prefix
    scconverter-alb-arn = aws_lb_target_group.scconverter-target-group.arn
    wopi_enabled = var.wopi_enabled ? true : false
    wopi_url = length(var.wopi_url) > 0 ? var.wopi_url : "https://${local.hostname}.wopi.securecircle.com"
    base_domain_alias = var.base_domain_alias,
    agent_upload_bucket = var.agent_upload_bucket,
    config_bucket = var.config_bucket,
    truststore_hash = aws_s3_bucket_object.truststore_jks.etag
    glowroot_enabled = var.glowroot_enabled
  }
}

