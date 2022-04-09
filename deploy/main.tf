terraform {
  required_providers {
    rustack = {
      source  = "pilat/rustack"
    }
  }
}

# Configure the Rustack Provider
provider "rustack" {
    api_endpoint = "https://cloud.nsalab.org"
    token = var.rustack_admin_token
}

resource "random_string" "learn" {
  length           = 8
  special          = false
  min_lower        = 2
  min_numeric      = 2
  upper            = false
}
