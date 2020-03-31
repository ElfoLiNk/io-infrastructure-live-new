dependency "resource_group" {
  config_path = "../../resource_group"

  mock_outputs = {
    resource_group_name = "fixture"
  }
}

dependency "virtual_network" {
  config_path = "../virtual_network"

  mock_outputs = {
    resource_group_name = "fixture"
  }
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_subnet?ref=v0.0.47"
}

inputs = {
  name                 = "appgateway"
  virtual_network_name = dependency.virtual_network.outputs.resource_name
  resource_group_name  = dependency.resource_group.outputs.resource_name
  address_prefix       = "10.251.1.64/26"
}