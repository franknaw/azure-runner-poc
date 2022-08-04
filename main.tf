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

/*
Azure Subscription Data Module
This module will return data about a specific Azure subscription
*/
module "subscription" {
  source          = "git::https://github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

/*
Azure Naming Module
This repository contains a list of variables and standards for naming resources in Microsoft Azure. It serves these primary purposes:

1. A central location for development teams to research and collaborate on allowed values and naming conventions.
2. A single source of truth for data values used in policy enforcement, billing, and naming.
3. A RESTful data source for application requiring information on approved values, variables and names.

This also show a great example of a github workflow that will deploy and run a RESTful API written in python.
*/
module "naming" {
  source = "git::https://github.com/Azure-Terraform/example-naming-template.git?ref=v1.0.0"
}

/*
Azure Metadata Module.
This module will return a map of mandatory tag for resources in Azure.

It is recommended that you always use this module to generate tags as it will prevent code duplication. 
Also, it's reccommended to leverage this data as "metadata" to determine core details about resources in other modules.
*/
module "metadata" {
  source = "git::https://github.com/Azure-Terraform/terraform-azurerm-metadata.git?ref=v1.5.0"

  naming_rules = module.naming.yaml

  market              = "us"
  project             = "https://github.com/franknaw/azure-runner-poc"
  location            = var.location
  environment         = "sandbox"
  product_name        = "runner1"
  business_unit       = "infra"
  product_group       = "fnaw"
  subscription_id     = module.subscription.output.subscription_id
  subscription_type   = "dev"
  resource_group_type = "app"

  depends_on = [
    module.subscription, module.naming
  ]
}

/*
Azure Resource Group Module
This module will create a new Resource Group in Azure.

Naming for this resource is as follows, based on published RBA naming convention
*/
module "resource_group" {
  source = "git::https://github.com/Azure-Terraform/terraform-azurerm-resource-group.git?ref=v2.0.0"

  location = module.metadata.location
  names    = module.metadata.names
  tags     = module.metadata.tags

  depends_on = [
    module.metadata
  ]
}

/*
Simple VNET Module
*/
module "vnet" {
  source = "git::https://github.com/franknaw/azure-simple-network.git?ref=v1.0.0"

  resource_group_name      = module.resource_group.name
  location                 = module.resource_group.location
  product_name             = module.metadata.names.product_name
  tags                     = module.metadata.tags
  address_space            = ["10.10.0.0/22"]
  address_prefixes_private = ["10.10.0.0/24"]
  address_prefixes_public  = ["10.10.1.0/24"]

  depends_on = [
    module.resource_group
  ]
}

/*
A Module to generate ssh PEM files
*/
module "pem" {
  source = "git::https://github.com/franknaw/azure-private-key.git?ref=v1.0.0"
  hosts  = local.hosts
}

/*
Simple Module for creating and installing a Github runner
*/
module "runner" {
  source              = "git::https://github.com/franknaw/azure-simple-github-runner.git?ref=v1.0.0"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  names               = module.metadata.names
  tags                = module.metadata.tags

  subnet_id = module.vnet.subnet_public.id

  username   = var.username
  public_key = module.pem.ssh_keys["runner"].public_key_openssh

  github_org_name     = var.gh_org_name
  github_runner_token = var.gh_runner_token
  github_runner_name  = var.gh_runner_name
  runner_labels       = ["sandbox"]

  depends_on = [
    module.vnet, module.pem
  ]
}

/*
Simple Module for creating a Bastion VM
*/
module "bastion" {
  source              = "git::https://github.com/franknaw/azure-simple-bastion.git?ref=v1.0.0"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  names               = module.metadata.names
  tags                = module.metadata.tags

  subnet_id = module.vnet.subnet_public.id

  username                   = var.username
  public_key                 = module.pem.ssh_keys["bastion"].public_key_openssh
  source_address_prefixes    = local.access_list
  destination_address_prefix = module.runner.private_ip

  depends_on = [
    module.runner
  ]
}
