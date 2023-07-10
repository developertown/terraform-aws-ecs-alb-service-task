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
