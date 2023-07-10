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
