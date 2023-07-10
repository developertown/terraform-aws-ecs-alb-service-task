variable "enabled" {
  type        = bool
  default     = null
  description = "Set to false to prevent the module from creating any resources"
}

variable "environment" {
  type        = string
  default     = null
  description = "ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'"
}

variable "name" {
  type        = string
  default     = "ecs-cluster"
  description = <<-EOT
    ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.
    This is the only ID element not also included as a `tag`.
    The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.
    EOT
}

variable "suffix" {
  type        = string
  default     = ""
  description = "Suffix to be added to the name of each resource"
}

variable "role_arn" {
  type        = string
  default     = null
  description = "The ARN of the role that will be assumed to create the resources in this module"
}

variable "region" {
  type        = string
  default     = null
  description = "The region in which the resources will be created"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
    Additional tags (e.g. `{'Unit': 'XYZ'}`).
    Neither the tag keys nor the tag values will be modified by this module.
    EOT
}