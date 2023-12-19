include "root" {
  path = find_in_parent_folders()
}

locals {
    common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
}

inputs = merge(
  local.common_vars.inputs,
  {
    # additional inputs
    vpc_cidr                 = "10.1.0.0/16"
    vpc_private_subnets      = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
    vpc_public_subnets       = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
  }
)