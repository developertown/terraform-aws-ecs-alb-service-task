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
