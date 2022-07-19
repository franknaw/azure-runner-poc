# variable "prefix" {
#   description = "The prefix used for all resources in this example"
#   default = "test"
# }

# variable "location" {
#   description = "The Azure location where all resources in this example should be created"
#   default = "East US"
# }

variable "location" {
  description = "github runner token"
  type        = string
}

variable "name" {
  description = "The name of the resource"
  type        = string
}

variable "gh_runner_token" {
  description = "The GitHub runner token."
  type        = string
  sensitive   = true
}

variable "gh_repo_name" {
  description = "The name of github repository."
  type        = string
  default     = null
}

variable "gh_org_name" {
  description = "The name of github organization or owner."
  type        = string
  default     = null
}