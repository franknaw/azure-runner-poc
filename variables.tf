variable "location" {
  description = "Azure location to deploy resources"
  type        = string
}

variable "gh_runner_token" {
  description = "The GitHub runner token."
  type        = string
  sensitive   = true
}

variable "gh_org_name" {
  description = "The name of github organization or owner."
  type        = string
}

variable "gh_runner_name" {
  description = "The name of github runner."
  type        = string
}
variable "username" {
  description = "the admin user for the VM"
  type        = string
}
