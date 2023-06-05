terraform {
  required_providers {
    aci = {
      source = "ciscodevnet/aci"
      version = "~> 2.1.0"
    }
  }
}

locals {
  tenants = ["foo", "bar", "foobar"]
}

provider "aci" {
  username = var.aciUser
  private_key = var.aciPrivateKey
  cert_name = var.aciCertName
  insecure = true
  url = var.aciUrl
}

resource "aci_tenant" "mytenant" {
  for_each = toset(local.tenants)
  description = var.tenantDescr
  name        = each.value
}


