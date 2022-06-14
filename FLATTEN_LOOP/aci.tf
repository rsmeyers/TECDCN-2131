terraform {
  required_providers {
    aci = {
      source = "ciscodevnet/aci"
      version = "~> 2.1.0"
    }
  }
}

provider "aci" {
  username = var.aciUser
  private_key = var.aciPrivateKey
  cert_name = var.aciCertName
  insecure = true
  url = var.aciUrl
}

locals {
  tenants     = ["foo", "bar", "foobar"]
  environment = ["prod", "preprod", "qa"]

  # Now let's create a tenant in each environment
  alltns = distinct(flatten([
    for tenant in local.tenants : [
      for env in local.environment : {
        tenant = tenant
        env = env
      }
    ]
  ]))
}


resource "aci_tenant" "mytenant" {
  for_each    = { for entry in local.alltns: "${entry.tenant}.${entry.env}" => entry }
  name        = each.key
}


