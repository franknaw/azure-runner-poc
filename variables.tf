variable "prefix" {
  description = "The prefix used for all resources in this example"
  default = "poc"
}

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

variable "admin_username" {
  description = "the admin user"
  type        = string
  default     = "adminuser"
}

variable "admin_password" {
  description = "the admin password. leave blank to assign a random password"
  type        = string
  sensitive   = true
  default     = null
}
