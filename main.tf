locals {
  enabled = var.enabled
  name    = "${var.name}-${var.environment}%{if var.suffix != ""}-${var.suffix}%{endif}"

  create_security_group = local.enabled && var.security_group_enabled

  log_group_name = "${local.name}-ecs-logs"
  secrets        = [for k, v in var.secrets : { name = k, valueFrom = v }]

  env_vars_keys        = var.map_environment_variables != null ? keys(var.map_environment_variables) : var.environment_variables != null ? [for m in var.environment_variables : lookup(m, "name")] : []
  env_vars_values      = var.map_environment_variables != null ? values(var.map_environment_variables) : var.environment_variables != null ? [for m in var.environment_variables : lookup(m, "value")] : []
  sorted_env_vars_keys = sort(local.env_vars_keys)
  env_vars_as_map      = zipmap(local.env_vars_keys, local.env_vars_values)
  sorted_environment_vars = [
    for key in local.sorted_env_vars_keys :
    {
      name  = key
      value = lookup(local.env_vars_as_map, key)
    }
  ]
  final_environment = length(local.sorted_environment_vars) > 0 ? local.sorted_environment_vars : null

  init_container = var.init_image_name != "" ? [{
    name        = var.init_image_name
    image       = "${var.init_image_repository}:${var.init_image_tag}"
    essential   = false
    environment = local.final_environment
    secrets     = local.secrets
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = local.log_group_name
        awslogs-region        = var.region
        awslogs-stream-prefix = var.init_image_name
      }
  } }] : []

  tags = merge({
    "Name"        = local.name,
    "Environment" = var.environment,
    "Terraform"   = "true"
  }, var.tags)
}

#tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "ecs_logs" {
  count = local.enabled ? 1 : 0

  name              = local.log_group_name
  retention_in_days = var.log_retention_days
}

resource "aws_ecs_service" "default" {
  count = local.enabled ? 1 : 0

  name                               = "${local.name}-service"
  cluster                            = var.cluster_id
  task_definition                    = aws_ecs_task_definition.task[0].arn
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = var.load_balancer_arn != "" ? 60 : null
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  force_new_deployment               = true

  network_configuration {
    security_groups  = var.cluster_security_groups
    subnets          = var.subnet_ids
    assign_public_ip = true
  }

  dynamic "load_balancer" {
    for_each = length(aws_lb_target_group.lb_target_group) != 0 ? [1] : []

    content {
      target_group_arn = aws_lb_target_group.lb_target_group[0].arn
      container_name   = var.image_name
      container_port   = var.cluster_port
    }
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_ecs_task_definition" "task" {
  count = local.enabled ? 1 : 0

  family                   = "${local.name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_role[0].arn
  task_role_arn            = aws_iam_role.ecs_task_role[0].arn
  container_definitions = jsonencode(concat(local.init_container, [{
    name        = var.image_name
    image       = "${var.image_repository}:${var.image_tag}"
    essential   = true
    environment = local.final_environment
    secrets     = local.secrets
    portMappings = [{
      protocol      = "tcp"
      containerPort = var.cluster_port
      hostPort      = var.cluster_port
    }]
    healthCheck = var.container_health_check
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = local.log_group_name
        awslogs-region        = var.region
        awslogs-stream-prefix = var.image_name
      }
    }
    dependsOn = var.init_image_name != "" ? [{
      containerName = var.init_image_name
      condition     = "SUCCESS"
    }] : []
  }]))
}

resource "aws_iam_role" "ecs_task_role" {
  count = local.enabled ? 1 : 0

  name = "${local.name}-ecsTaskRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_lb_target_group" "lb_target_group" {
  count = local.enabled && var.load_balancer_arn != "" ? 1 : 0

  name        = "${local.name}-alb-target-group"
  port        = var.cluster_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled  = var.load_balancer_health_check.enabled
    port     = var.cluster_port
    protocol = var.load_balancer_health_check.protocol
    path     = var.load_balancer_health_check.path
    matcher  = var.load_balancer_health_check.matcher
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "host_based_weighted_routing" {
  count = local.enabled && var.load_balancer_arn != "" ? 1 : 0

  listener_arn = var.load_balancer_listener_arn
  priority     = var.alb_listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group[0].arn
  }

  condition {
    host_header {
      values = [var.service_url]
    }
  }
}

resource "aws_security_group" "ecs_service" {
  count       = local.create_security_group ? 1 : 0
  vpc_id      = var.vpc_id
  name        = "${local.name}-sg"
  description = var.security_group_description
  tags        = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_all_egress" {
  count             = local.create_security_group && var.enable_all_egress_rule ? 1 : 0
  description       = "Allow all outbound traffic to any IPv4 address"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.ecs_service.*.id)
}

resource "aws_security_group_rule" "allow_icmp_ingress" {
  count             = local.create_security_group && var.enable_icmp_rule ? 1 : 0
  description       = "Allow ping command from anywhere, see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/security-group-rules-reference.html#sg-rules-ping"
  type              = "ingress"
  from_port         = 8
  to_port           = 0
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.ecs_service.*.id)
}

resource "aws_security_group_rule" "alb" {
  count                    = local.create_security_group && var.use_alb_security_group ? 1 : 0
  description              = "Allow inbound traffic from ALB"
  type                     = "ingress"
  from_port                = var.cluster_port
  to_port                  = var.cluster_port
  protocol                 = "tcp"
  source_security_group_id = var.alb_security_group
  security_group_id        = join("", aws_security_group.ecs_service.*.id)
}

resource "aws_appautoscaling_target" "service_target" {
  count = local.enabled ? 1 : 0

  max_capacity       = var.max_count
  min_capacity       = var.min_count
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.default[0].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  count = local.enabled ? 1 : 0

  name               = "${local.name}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.service_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.service_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.service_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 80
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  count = local.enabled ? 1 : 0

  name               = "${local.name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.service_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.service_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.service_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
  }
}

module "log_metric_error_filter" {
  count   = local.enabled && var.sns_alarm_topic_arn != "" ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-metric-filter"
  version = "~> 4.2.0"

  log_group_name = local.log_group_name

  name    = "ECS Service - Log Errors"
  pattern = "ERROR"

  metric_transformation_namespace = "LogMetrics"
  metric_transformation_name      = "ECSServiceErrorCount"
  metric_transformation_value     = "1"
}

module "log_metric_default_filter" {
  count   = local.enabled && var.sns_alarm_topic_arn != "" ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-metric-filter"
  version = "~> 4.2.0"

  log_group_name = local.log_group_name

  name    = "ECS Service - Log Default"
  pattern = ""

  metric_transformation_namespace = "LogMetrics"
  metric_transformation_name      = "ECSServiceErrorCount"
  metric_transformation_value     = "0"
}

module "metric_alarm_log_error" {
  count   = local.enabled && var.sns_alarm_topic_arn != "" ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 4.2.0"

  alarm_name          = "ECS Service - Error"
  alarm_description   = "Errors occured in the ECS Service"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.alarm_error_threshold
  period              = 300

  namespace   = "LogMetrics"
  metric_name = "ECSServiceErrorCount"
  statistic   = "Average"

  alarm_actions = [var.sns_alarm_topic_arn]
}

module "metric_alarm_cpu" {
  count   = local.enabled && var.sns_alarm_topic_arn != "" ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 4.2.0"

  alarm_name          = "ECS Service - CPU Usage High"
  alarm_description   = "CPU Usage Exceeds ${var.alarm_cpu_threshold}%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.alarm_cpu_threshold
  period              = 300

  namespace   = "AWS/ECS"
  metric_name = "CPUUtilization"
  statistic   = "Average"

  dimensions = {
    ServiceName = "${local.name}-service",
    ClusterName = var.cluster_name
  }

  alarm_actions = [var.sns_alarm_topic_arn]
}

module "metric_alarm_memory" {
  count   = local.enabled && var.sns_alarm_topic_arn != "" ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 4.2.0"

  alarm_name          = "ECS Service - Memory Usage High"
  alarm_description   = "Memory Usage Exceeds ${var.alarm_memory_threshold}%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.alarm_memory_threshold
  period              = 300

  namespace   = "AWS/ECS"
  metric_name = "MemoryUtilization"
  statistic   = "Average"

  dimensions = {
    ServiceName = "${local.name}-service",
    ClusterName = var.cluster_name
  }

  alarm_actions = [var.sns_alarm_topic_arn]
}
