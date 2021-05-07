resource "aws_autoscaling_group" "mumbai-ec2-asg" {

  mixed_instances_policy {
    instances_distribution {
      on_demand_allocation_strategy = "prioritized"
      on_demand_percentage_above_base_capacity = var.percent_on_demand
      spot_allocation_strategy = "capacity-optimized"
      spot_max_price = 0.0188
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.mumbai-ec2-lt.id
        version = "$Latest"
      }
      dynamic "override" {
        for_each = var.asg_lt_instance_type_overrides[var.region]
        content {
          instance_type = override.value.instance_type
        }
      }
    }
  }
  name_prefix = "${var.name_prefix}-ec2-asg-"
  max_size = 2
  min_size = 2
  desired_capacity = 2
  vpc_zone_identifier = [aws_subnet.private_0.id, aws_subnet.private_1.id]
  health_check_grace_period = 900
  health_check_type = "ELB"
  target_group_arns = [aws_lb_target_group.ec2-nlb-target-group.arn, aws_lb_target_group.scconverter-target-group.arn]
  wait_for_capacity_timeout = "15m"
  wait_for_elb_capacity = 1
  tag {
    key = "Name"
    value = "${var.name_prefix}-ec2-member"
    propagate_at_launch = true
  }
  dynamic "tag" {
    for_each = local.common_tags
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_db_instance.scdb,
    aws_lb_listener.nlb-listener-443,
    aws_lb_listener.nlb-listener-scconverter
  ]

}
