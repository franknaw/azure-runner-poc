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
  validation {
    condition     = (contains(["runner1", "runner2"], lower(var.gh_runner_name)))
    error_message = "The GitHub runner name can only be \"runner1\" or \"runner2\"."
  }
}

variable "username" {
  description = "the admin user for the VM"
  type        = string
}
