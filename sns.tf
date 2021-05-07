resource "aws_sns_topic" "saas_alerts" {
  display_name = "${var.name_prefix} - SecureCircle SaaS"
  name = "${var.name_prefix}-saas-alerts-sns-topic"
  tags = local.common_tags
}

resource "null_resource" "saas_alerts_email_subscription" {
  count = length(var.saas_alerts_emails)
  provisioner "local-exec" {
    on_failure = continue
    command = "aws --region ${var.region} sns subscribe --topic-arn ${aws_sns_topic.saas_alerts.arn} --protocol email --notification-endpoint \"${var.saas_alerts_emails[count.index]}\""
  }
  triggers = {
    sns_topic = aws_sns_topic.saas_alerts.arn
    sns_subscriber = var.saas_alerts_emails[count.index]
  }
}
