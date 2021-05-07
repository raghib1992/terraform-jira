resource "aws_cloudwatch_log_group" "ecs-service-log-group" {
  name = "ecs-service-${var.name_prefix}-logs"
  retention_in_days = 180

  tags = local.common_tags
}
