terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {
  token = var.github_token
}

variable "github_token" {}
variable "repo" { default = "InfinityXone/infinity_x_one" }

# Read keys from master.env
locals {
  secrets = {
    for line in split("\n", file("/opt/infinity_x_one/env/master.env")) :
    split("=", line)[0] => split("=", line)[1]
    if length(trimspace(line)) > 0 && !startswith(line, "#")
  }
}

resource "github_actions_secret" "repo_secrets" {
  for_each      = local.secrets
  repository    = var.repo
  secret_name   = each.key
  plaintext_value = each.value
}
