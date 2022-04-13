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

