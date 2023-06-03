terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}