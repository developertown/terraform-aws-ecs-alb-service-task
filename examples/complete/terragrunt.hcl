skip = true

# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------
remote_state {
  backend = "local"
  config = {
    path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/terraform.tfstate"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}

# When using this terragrunt config, terragrunt will generate the file "provider-aws.tf" with the aws provider block before
# calling to terraform. Note that this will overwrite the `provider.tf` file if it already exists.
generate "provider" {
  path      = "provider-aws.tf"
  if_exists = "skip" # Allow modules to override provider settings
  contents = <<EOF
provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}
EOF
}

#terraform {
#  before_hook "before_hook" {
#    commands = ["validate"]
#    execute  = ["tfsec", "."]
#  }
#
#  before_hook "before_hook" {
#    commands = ["validate"]
#    execute  = ["tflint"]
#  }
#}
