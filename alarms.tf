resource "aws_cloudwatch_metric_alarm" "lb_unhealthy_host_count_alarm" {
  alarm_name = "${var.name_prefix}-lb-unhealthy-host-count-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  dimensions = {
    LoadBalancer = aws_lb.ec2-nlb.arn_suffix
    TargetGroup = aws_lb_target_group.ec2-nlb-target-group.arn_suffix
  }
  evaluation_periods = 1
  metric_name = "UnHealthyHostCount"
  namespace = "AWS/NetworkELB"
  period = 60
  statistic = "Maximum"
  threshold = 1
  treat_missing_data = "breaching"
  alarm_actions = [ aws_sns_topic.saas_alerts.arn ]
  tags = local.common_tags
  depends_on = [
    aws_autoscaling_group.mumbai-ec2-asg
  ]
}
