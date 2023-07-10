# terraform-aws-ecs-alb-service-task

Terraform module to provision an [ECS Service](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html) with [Task Definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html) and [CloudWatch Logs](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_cloudwatch_logs.html) configuration.

Supports [Amazon ECS Fargate](https://docs.aws.amazon.com/AmazonECS/latest/userguide/fargate-capacity-providers.html) capacity provider.

## Usage

### Basic

```hcl
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/developertown/terraform-aws-ecs-cluster.git///?ref=v1.0.1"
}

inputs = {
  enabled = true

  region             = "us-east-2"
  availability_zones = ["us-east-2b", "us-east-2c"]
  environment        = "test"

  name = "example"
}
```

```hcl
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/developertown/terraform-aws-vpc.git///?ref=v1.0.0"
}

inputs = {
  enabled = true

  name        = "example"
  region      = "us-east-2"
  environment = "test"

  azs = ["us-east-2b", "us-east-2c"]

  vpc_cidr = "10.0.0.0/16"

  private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
  public_subnets  = ["10.0.2.0/24", "10.0.3.0/24"]

  private_subnet_names = ["Private Subnet One", "Private Subnet Two"]

  create_database_subnet_group  = false
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false
  enable_dns_hostnames          = true
  enable_dns_support            = true
  enable_nat_gateway            = true
  single_nat_gateway            = true
  enable_vpn_gateway            = true
}

```

```hcl
include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../..//."
}

dependency "cluster" {
  config_path = "../cluster"

  mock_outputs = {
    id              = "cluster-1234567890"
    name            = "developertown-ecs"
    security_groups = ["sg-1234567890"]
  }
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    vpc_id                    = "vpc-1234567890"
    private_subnets           = ["subnet-1234567890", "subnet-1234567890"]
    default_security_group_id = "sg-1234567890"
  }
}

inputs = {
  name        = "test-svc"
  region      = "us-east-2"
  environment = "test"

  vpc_id     = dependency.network.outputs.vpc_id
  subnet_ids = dependency.network.outputs.private_subnets
  cluster_security_groups = [
    dependency.network.outputs.default_security_group_id
  ]

  cluster_id   = dependency.cluster.outputs.id
  cluster_name = dependency.cluster.outputs.name
  cluster_port = 1337

  image_name       = "geodesic"
  image_repository = "cloudposse/geodesic"
  image_tag        = "latest"

  environment_variables = [
    {
      name  = "string_var"
      value = "I am a string"
    },
    {
      name  = "true_boolean_var"
      value = true
    },
    {
      name  = "false_boolean_var"
      value = false
    },
    {
      name  = "integer_var"
      value = 42
    }
  ]

  tags = {
    "CreatedBy" = "Terraform"
    "Company"   = "DeveloperTown"
  }
}

```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.36.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.36.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_log_metric_default_filter"></a> [log\_metric\_default\_filter](#module\_log\_metric\_default\_filter) | terraform-aws-modules/cloudwatch/aws//modules/log-metric-filter | ~> 4.2.0 |
| <a name="module_log_metric_error_filter"></a> [log\_metric\_error\_filter](#module\_log\_metric\_error\_filter) | terraform-aws-modules/cloudwatch/aws//modules/log-metric-filter | ~> 4.2.0 |
| <a name="module_metric_alarm_cpu"></a> [metric\_alarm\_cpu](#module\_metric\_alarm\_cpu) | terraform-aws-modules/cloudwatch/aws//modules/metric-alarm | ~> 4.2.0 |
| <a name="module_metric_alarm_log_error"></a> [metric\_alarm\_log\_error](#module\_metric\_alarm\_log\_error) | terraform-aws-modules/cloudwatch/aws//modules/metric-alarm | ~> 4.2.0 |
| <a name="module_metric_alarm_memory"></a> [metric\_alarm\_memory](#module\_metric\_alarm\_memory) | terraform-aws-modules/cloudwatch/aws//modules/metric-alarm | ~> 4.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.ecs_policy_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.ecs_policy_memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.service_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.ecs_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_instance_profile.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb_listener_rule.host_based_weighted_routing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.lb_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.ecs_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_all_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_icmp_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_iam_policy_document.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_cpu_threshold"></a> [alarm\_cpu\_threshold](#input\_alarm\_cpu\_threshold) | CPU Percentage that should cause an alarm if the actual cpu average is greater than or equal for 300 seconds | `number` | `90` | no |
| <a name="input_alarm_error_threshold"></a> [alarm\_error\_threshold](#input\_alarm\_error\_threshold) | Number of error logs that should cause an alarm when the average is greater than or equal for 300 seconds | `number` | `100` | no |
| <a name="input_alarm_memory_threshold"></a> [alarm\_memory\_threshold](#input\_alarm\_memory\_threshold) | Memory Percentage that should cause an alarm if the actual memory average is greater than or equal for 300 seconds | `number` | `90` | no |
| <a name="input_alb_listener_rule_priority"></a> [alb\_listener\_rule\_priority](#input\_alb\_listener\_rule\_priority) | The priority of the ALB listener rule | `number` | `100` | no |
| <a name="input_alb_security_group"></a> [alb\_security\_group](#input\_alb\_security\_group) | Security group of the ALB | `string` | `""` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | The ARN of an ECS cluster | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the ECS cluster, used to identify the autoscaling resource target | `string` | `""` | no |
| <a name="input_cluster_port"></a> [cluster\_port](#input\_cluster\_port) | The ECS Cluster / ECS Task Port Mapping | `number` | `5000` | no |
| <a name="input_cluster_security_groups"></a> [cluster\_security\_groups](#input\_cluster\_security\_groups) | The security groups to associate with the ecs service | `list(string)` | `[]` | no |
| <a name="input_container_health_check"></a> [container\_health\_check](#input\_container\_health\_check) | The container health check | <pre>object({<br>    retries     = number<br>    command     = list(string)<br>    timeout     = number<br>    interval    = number<br>    startPeriod = number<br>  })</pre> | `null` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Number of cpu units used by the ecs service | `number` | `512` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Number of instances of the task definition to place and keep running | `number` | `2` | no |
| <a name="input_enable_all_egress_rule"></a> [enable\_all\_egress\_rule](#input\_enable\_all\_egress\_rule) | Whether to create a security group rule that allows all outbound traffic | `bool` | `true` | no |
| <a name="input_enable_icmp_rule"></a> [enable\_icmp\_rule](#input\_enable\_icmp\_rule) | Whether to create a security group rule that allows ICMP traffic | `bool` | `true` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | The environment variables to pass to the container. This is a list of maps. map\_environment overrides environment | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | `[]` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | The name of the image to pull from Amazon ECR | `string` | `""` | no |
| <a name="input_image_repository"></a> [image\_repository](#input\_image\_repository) | The name of the ECR image repository | `string` | `""` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | The tag of the image to pull from Amazon ECR | `string` | `""` | no |
| <a name="input_init_image_name"></a> [init\_image\_name](#input\_init\_image\_name) | The name of the init container image to pull from Amazon ECR | `string` | `""` | no |
| <a name="input_init_image_repository"></a> [init\_image\_repository](#input\_init\_image\_repository) | The name of the init container ECR image repository | `string` | `""` | no |
| <a name="input_init_image_tag"></a> [init\_image\_tag](#input\_init\_image\_tag) | The tag of the init container image to pull from Amazon ECR | `string` | `""` | no |
| <a name="input_load_balancer_arn"></a> [load\_balancer\_arn](#input\_load\_balancer\_arn) | ARN of the Load Balancer to associate with the service | `string` | `""` | no |
| <a name="input_load_balancer_health_check"></a> [load\_balancer\_health\_check](#input\_load\_balancer\_health\_check) | The load balancer health check | <pre>object({<br>    enabled  = bool<br>    matcher  = string<br>    path     = string<br>    protocol = string<br>  })</pre> | <pre>{<br>  "enabled": false,<br>  "matcher": "200-399",<br>  "path": "/",<br>  "protocol": "HTTP"<br>}</pre> | no |
| <a name="input_load_balancer_listener_arn"></a> [load\_balancer\_listener\_arn](#input\_load\_balancer\_listener\_arn) | ARN of the Load Balancer listener to associate with the service | `string` | `""` | no |
| <a name="input_load_balancer_target_group_arn"></a> [load\_balancer\_target\_group\_arn](#input\_load\_balancer\_target\_group\_arn) | ARN of the Load Balancer target group to associate with the service | `string` | `""` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days to retain logs | `number` | `7` | no |
| <a name="input_map_environment_variables"></a> [map\_environment\_variables](#input\_map\_environment\_variables) | A set of key/value to provide as environment variables to the ecs task | `map(string)` | `null` | no |
| <a name="input_max_count"></a> [max\_count](#input\_max\_count) | Maxiumum number of instances of the task definition to place and keep running | `number` | `4` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount (in MiB) of memory used by the ecs service | `number` | `1024` | no |
| <a name="input_min_count"></a> [min\_count](#input\_min\_count) | Minimum number of instances of the task definition to place and keep running | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `"ecs-cluster"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region in which the resources will be created | `string` | `null` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | The ARN of the role that will be assumed to create the resources in this module | `string` | `null` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | A set of key/value secret pairs to read from secrets manager and provide as environment variables to the ecs task | `map(string)` | `{}` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | The description of the security group | `string` | `"Security group for the service"` | no |
| <a name="input_security_group_enabled"></a> [security\_group\_enabled](#input\_security\_group\_enabled) | Whether to create a security group for the service | `bool` | `true` | no |
| <a name="input_service_url"></a> [service\_url](#input\_service\_url) | The URL of the service | `string` | `""` | no |
| <a name="input_sns_alarm_topic_arn"></a> [sns\_alarm\_topic\_arn](#input\_sns\_alarm\_topic\_arn) | The SNS Topic ARN to use for Cloudwatch Alarms | `string` | `""` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The subnets to associate with the ecs service | `list(string)` | `[]` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | Suffix to be added to the name of each resource | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'Unit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_use_alb_security_group"></a> [use\_alb\_security\_group](#input\_use\_alb\_security\_group) | A flag to enable/disable allowing traffic from the ALB security group to the service security group | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID to associate with the ecs service | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_arn"></a> [service\_arn](#output\_service\_arn) | ECS Service ARN |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | ECS Service name |
| <a name="output_service_security_group_id"></a> [service\_security\_group\_id](#output\_service\_security\_group\_id) | Security Group ID of the ECS task |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | ECS task definition ARN |
| <a name="output_task_definition_family"></a> [task\_definition\_family](#output\_task\_definition\_family) | ECS task definition family |
| <a name="output_task_definition_revision"></a> [task\_definition\_revision](#output\_task\_definition\_revision) | ECS task definition revision |
