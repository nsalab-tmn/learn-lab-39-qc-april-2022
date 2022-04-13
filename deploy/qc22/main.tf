terraform {
  required_providers {
    rustack = {
      source = "pilat/rustack"
      version = "1.0.5"
    }

    random = {
      version = "~> 3.1.0"
      source  = "hashicorp/random"
    }
  }
}


resource "random_string" "learn" {
  length           = 8
  special          = false
  min_lower        = 2
  min_numeric      = 2
  upper            = false
}

resource "random_string" "eve_passwd" {
  length           = 8
  special          = false
  min_lower        = 2
  min_numeric      = 2
  upper            = false
}