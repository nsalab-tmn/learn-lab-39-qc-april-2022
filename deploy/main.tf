terraform {
  required_providers {
    rustack = {
      source  = "pilat/rustack"
    }
    restapi = {
      source = "Mastercard/restapi"
    }
  }
}

# Configure the Rustack Provider
provider "rustack" {
    api_endpoint = "https://cloud.nsalab.org"
    token = var.rustack_admin_token
}

provider "restapi" {
  # Default provider for rest API to avoid error on destroy WRT uri argument
  # https://github.com/hashicorp/terraform/issues/21330
  uri                  = "dummy"
}

provider "restapi" {
  alias                = "restapi_headers"
  uri                  = "${var.rustack_api_endpoint}/v1"
  debug                = true
  write_returns_object = true

  headers = {
    Authorization = "Bearer ${var.rustack_root_token}"
  }
}

provider "restapi" {
  alias                = "restapi_admin"
  uri                  = "${var.rustack_api_endpoint}/v1"
  debug                = true
  write_returns_object = true

  headers = {
    Authorization = "Bearer ${var.rustack_admin_token}"
  }
}
resource "random_string" "learn" {
  length           = 8
  special          = false
  min_lower        = 2
  min_numeric      = 2
  upper            = false
}
