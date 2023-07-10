output "service_name" {
  description = "ECS Service name"
  value       = try(aws_ecs_service.default[0].name, "")
}

output "service_arn" {
  description = "ECS Service ARN"
  value       = try(aws_ecs_service.default[0].id, "")
}

output "service_security_group_id" {
  description = "Security Group ID of the ECS task"
  value       = join("", aws_security_group.ecs_service.*.id)
}

output "task_definition_family" {
  description = "ECS task definition family"
  value       = join("", aws_ecs_task_definition.task.*.family)
}

output "task_definition_revision" {
  description = "ECS task definition revision"
  value       = join("", aws_ecs_task_definition.task.*.revision)
}

output "task_definition_arn" {
  description = "ECS task definition ARN"
  value       = join("", aws_ecs_task_definition.task.*.arn)
}
