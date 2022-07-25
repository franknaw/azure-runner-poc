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

locals {
  hosts = toset(["bastion", "runner"])
  access_list = {
    my_ip = "${chomp(data.http.my_ip.body)}/32"
  }
}

data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "azurerm_subscription" "current" {
}


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

# resource "random_string" "random" {
#   length  = 12
#   upper   = false
#   special = false
# }

module "pem" {
  source ="git::https://github.com/franknaw/azure-private-key.git"
  hosts = local.hosts 
}

module "vnet" {
  source = "git::https://github.com/franknaw/azure-simple-network.git"

  # naming_rules = module.naming.yaml

  resource_group_name      = module.resource_group.name
  location                 = module.resource_group.location
  names                    = module.metadata.names
  tags                     = module.metadata.tags
  address_space            = ["10.0.0.0/22"]
  address_prefixes_private = ["10.0.1.0/24"]
  address_prefixes_public  = ["10.0.2.0/24"]
}

module "bastion" {
  source = "git::https://github.com/franknaw/azure-simple-bastion.git" 
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  names               = module.metadata.names
  tags                = module.metadata.tags

  subnet_id = module.vnet.subnet_public.id

  username                   = "adminuser"
  public_key                 = module.pem.ssh_keys["bastion"].public_key_pem
  source_address_prefixes    = local.access_list
  destination_address_prefix = module.runner.private_ip

}
module "runner" {
  source              = "git::https://github.com/franknaw/azure-simple-github-runner"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = var.name
  tags                = module.metadata.tags

  subnet_id = module.vnet.subnet_private.id

  runner_scope     = "repo"
  runner_os        = "linux"
  github_repo_name = var.gh_repo_name
  github_org_name  = var.gh_org_name
  ## gen repo runner token https://github.community/t/api-to-generate-runners-token/16963
  github_runner_token = var.gh_runner_token

  enable_boot_diagnostics = true

  username   = "adminuser"
  public_key                 = module.pem.ssh_keys["runner"].public_key_pem


  runner_labels = ["azure", "dev"]
}
