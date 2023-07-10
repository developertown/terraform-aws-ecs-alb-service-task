# terraform-aws-ecs-cluster

Terraform module to provision an [`ECS Cluster`](https://aws.amazon.com/en/ecs/).

Supports [Amazon ECS Fargate](https://docs.aws.amazon.com/AmazonECS/latest/userguide/fargate-capacity-providers.html) capacity provider.

## Usage

### Basic

```hcl
module "ecs_cluster" {
  source  = "../.."
  enabled = true

  name        = "example"
  environment = "test"

  container_insights_enabled      = true
  capacity_providers_fargate      = true
  capacity_providers_fargate_spot = true
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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_iam_instance_profile.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_capacity_providers_fargate"></a> [capacity\_providers\_fargate](#input\_capacity\_providers\_fargate) | Use FARGATE capacity provider | `bool` | `true` | no |
| <a name="input_capacity_providers_fargate_spot"></a> [capacity\_providers\_fargate\_spot](#input\_capacity\_providers\_fargate\_spot) | Use FARGATE\_SPOT capacity provider | `bool` | `false` | no |
| <a name="input_container_insights_enabled"></a> [container\_insights\_enabled](#input\_container\_insights\_enabled) | Whether or not to enable container insights | `bool` | `true` | no |
| <a name="input_default_capacity_strategy"></a> [default\_capacity\_strategy](#input\_default\_capacity\_strategy) | The capacity provider strategy to use by default for the cluster | <pre>object({<br>    base = object({<br>      provider = string<br>      value    = number<br>    })<br>    weights = map(number)<br>  })</pre> | <pre>{<br>  "base": {<br>    "provider": "FARGATE",<br>    "value": 1<br>  },<br>  "weights": {}<br>}</pre> | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The AWS Key Management Service key ID to encrypt the data between the local client and the container. | `string` | `null` | no |
| <a name="input_log_configuration"></a> [log\_configuration](#input\_log\_configuration) | The log configuration for the results of the execute command actions Required when logging is OVERRIDE | <pre>object({<br>    cloud_watch_encryption_enabled = string<br>    cloud_watch_log_group_name     = string<br>    s3_bucket_name                 = string<br>    s3_key_prefix                  = string<br>  })</pre> | `null` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | The AWS Key Management Service key ID to encrypt the data between the local client and the container. (Valid values: 'NONE', 'DEFAULT', 'OVERRIDE') | `string` | `"DEFAULT"` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `"ecs-cluster"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region in which the resources will be created | `string` | `null` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | The ARN of the role that will be assumed to create the resources in this module | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'Unit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ECS cluster arn |
| <a name="output_id"></a> [id](#output\_id) | ECS cluster id |
| <a name="output_name"></a> [name](#output\_name) | ECS cluster name |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | IAM role name |
<<<<<<< Updated upstream

=======
