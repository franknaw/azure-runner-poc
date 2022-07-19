terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

# output "subscription" {
#   value = data.azurerm_subscription.current
# }

module "subscription" {
  source          = "git::https://github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

module "naming" {
  source = "git::https://github.com/Azure-Terraform/example-naming-template.git?ref=v1.0.0"
}

module "metadata" {
  source = "git::https://github.com/Azure-Terraform/terraform-azurerm-metadata.git?ref=v1.5.0"

  naming_rules = module.naming.yaml

  market              = "us"
  project             = "https://github.com/Azure-Terraform/terraform-azurerm-virtual-network/tree/master/example/bastion"
  location            = "eastus2"
  environment         = "sandbox"
  product_name        = "runner1"
  business_unit       = "infra"
  product_group       = "fnaw"
  subscription_id     = module.subscription.output.subscription_id
  subscription_type   = "dev"
  resource_group_type = "app"
}

module "resource_group" {
  source = "git::https://github.com/Azure-Terraform/terraform-azurerm-resource-group.git?ref=v2.0.0"

  location = module.metadata.location
  names    = module.metadata.names
  tags     = module.metadata.tags
}

module "virtual_network" {
  source = "git::https://github.com/Azure-Terraform/terraform-azurerm-virtual-network.git?ref=v5.0.0"

  naming_rules = module.naming.yaml

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  names               = module.metadata.names
  tags                = module.metadata.tags

  address_space = ["10.1.0.0/24"]

  subnets = {
    "iaas-private" = {
      cidrs                   = ["10.1.0.0/24"]
      allow_vnet_inbound      = true
      allow_vnet_outbound     = true
      allow_internet_outbound = true
      service_endpoints       = ["Microsoft.Storage"]
    }
  }
}

module "storage_account" {
  source                    = "git::https://github.com/Azure-Terraform/terraform-azurerm-storage-account.git?ref=v0.12.1"
  resource_group_name       = module.resource_group.name
  location                  = module.resource_group.location
  tags                      = module.metadata.tags
  account_kind              = "StorageV2"
  replication_type          = "LRS"
  account_tier              = "Standard"
  default_network_rule      = "Allow"
  shared_access_key_enabled = true
  traffic_bypass            = ["AzureServices", "Logging"]
  service_endpoints = {
    "iaas-outbound" = module.virtual_network.subnet["iaas-private"].id
  }
}


module "runner" {
  source              = "./runner"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = var.name
  tags                = module.metadata.tags

  subnet_id = module.virtual_network.subnets["iaas-private"].id

  runner_scope     = "repo"
  runner_os        = "linux"
  github_repo_name = var.gh_repo_name
  github_org_name  = var.gh_org_name
  ## gen repo runner token https://github.community/t/api-to-generate-runners-token/16963
  github_runner_token = var.gh_runner_token

  enable_boot_diagnostics         = true
  diagnostics_storage_account_uri = module.storage_account.primary_blob_endpoint

  runner_labels = ["azure", "dev"]
}







# References
# https://github.com/waylew-lexis/terraform-azurerm-github-runner