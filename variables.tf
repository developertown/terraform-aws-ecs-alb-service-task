variable "vpc_id" {
  type        = string
  description = "The VPC ID to associate with the ecs service"
  default     = ""
}

variable "load_balancer_arn" {
  type        = string
  description = "ARN of the Load Balancer to associate with the service"
  default     = ""
}

variable "container_health_check" {
  type = object({
    retries     = number
    command     = list(string)
    timeout     = number
    interval    = number
    startPeriod = number
  })

  description = "The container health check"
  default     = null
}

variable "load_balancer_health_check" {
  type = object({
    enabled  = bool
    matcher  = string
    path     = string
    protocol = string
  })

  description = "The load balancer health check"
  default = {
    enabled  = false
    matcher  = "200-399"
    path     = "/"
    protocol = "HTTP"
  }
}

variable "load_balancer_listener_arn" {
  type        = string
  description = "ARN of the Load Balancer listener to associate with the service"
  default     = ""
}

variable "subnet_ids" {
  type        = list(string)
  description = "The subnets to associate with the ecs service"
  default     = []
}

variable "cluster_security_groups" {
  description = "The security groups to associate with the ecs service"
  type        = list(string)
  default     = []
}

variable "cluster_id" {
  type        = string
  description = "The ARN of an ECS cluster"
  default     = ""
}

variable "cluster_name" {
  type        = string
  description = " The name of the ECS cluster, used to identify the autoscaling resource target"
  default     = ""
}

variable "cluster_port" {
  type        = number
  description = "The ECS Cluster / ECS Task Port Mapping"
  default     = 5000
}

variable "load_balancer_target_group_arn" {
  type        = string
  description = "ARN of the Load Balancer target group to associate with the service"
  default     = ""
}

variable "cpu" {
  type        = number
  description = "Number of cpu units used by the ecs service"
  default     = 512
}

variable "memory" {
  type        = number
  description = "Amount (in MiB) of memory used by the ecs service"
  default     = 1024
}

variable "desired_count" {
  type        = number
  description = "Number of instances of the task definition to place and keep running"
  default     = 2
}

variable "min_count" {
  type        = number
  description = "Minimum number of instances of the task definition to place and keep running"
  default     = 1
}

variable "max_count" {
  type        = number
  description = "Maxiumum number of instances of the task definition to place and keep running"
  default     = 4
}

variable "image_repository" {
  type        = string
  description = "The name of the ECR image repository"
  default     = ""
}

variable "image_name" {
  type        = string
  description = "The name of the image to pull from Amazon ECR"
  default     = ""
}

variable "image_tag" {
  type        = string
  description = "The tag of the image to pull from Amazon ECR"
  default     = ""
}

variable "secrets" {
  description = "A set of key/value secret pairs to read from secrets manager and provide as environment variables to the ecs task"
  type        = map(string)
  default     = {}
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "The environment variables to pass to the container. This is a list of maps. map_environment overrides environment"
  default     = []
}

variable "map_environment_variables" {
  description = "A set of key/value to provide as environment variables to the ecs task"
  type        = map(string)
  default     = null
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain logs"
  default     = 7
}

variable "init_image_name" {
  type        = string
  description = "The name of the init container image to pull from Amazon ECR"
  default     = ""
}

variable "init_image_repository" {
  type        = string
  description = "The name of the init container ECR image repository"
  default     = ""
}

variable "init_image_tag" {
  type        = string
  description = "The tag of the init container image to pull from Amazon ECR"
  default     = ""
}

variable "sns_alarm_topic_arn" {
  type        = string
  description = "The SNS Topic ARN to use for Cloudwatch Alarms"
  default     = ""
}

variable "alarm_cpu_threshold" {
  type        = number
  description = "CPU Percentage that should cause an alarm if the actual cpu average is greater than or equal for 300 seconds"
  default     = 90
}

variable "alarm_memory_threshold" {
  type        = number
  description = "Memory Percentage that should cause an alarm if the actual memory average is greater than or equal for 300 seconds"
  default     = 90
}

variable "alarm_error_threshold" {
  type        = number
  description = "Number of error logs that should cause an alarm when the average is greater than or equal for 300 seconds"
  default     = 100
}

variable "service_url" {
  type        = string
  description = "The URL of the service"
  default     = ""
}

variable "alb_listener_rule_priority" {
  type        = number
  description = "The priority of the ALB listener rule"
  default     = 100
}

variable "security_group_enabled" {
  type        = bool
  description = "Whether to create a security group for the service"
  default     = true
}

variable "security_group_description" {
  type        = string
  description = "The description of the security group"
  default     = "Security group for the service"
}

variable "enable_all_egress_rule" {
  type        = bool
  description = "Whether to create a security group rule that allows all outbound traffic"
  default     = true
}

variable "enable_icmp_rule" {
  type        = bool
  description = "Whether to create a security group rule that allows ICMP traffic"
  default     = true
}

variable "use_alb_security_group" {
  description = "A flag to enable/disable allowing traffic from the ALB security group to the service security group"
  type        = bool
  default     = false
}

variable "alb_security_group" {
  type        = string
  description = "Security group of the ALB"
  default     = ""
}