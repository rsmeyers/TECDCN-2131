terraform {
  required_providers {
    aci = {
      source = "ciscodevnet/aci"
      version = "~> 2.1.0"
    }
  }
}

locals {
  dothis = "true"
}

provider "aci" {
  username = var.aciUser
  private_key = var.aciPrivateKey
  cert_name = var.aciCertName
  insecure = true
  url = var.aciUrl
}

resource "aci_tenant" "mytenant" {
  count = local.dothis ? 5 : 0
  description = var.tenantDescr
  name        = "${var.tenantName}-${count.index}"
}


