include "root" {
  path = find_in_parent_folders()
}

locals {
    common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = merge(
  local.common_vars.inputs,
  {
    vpc_id = dependency.vpc.outputs.vpc.vpc_id
    private_subnets = dependency.vpc.outputs.vpc.private_subnets
  }
)