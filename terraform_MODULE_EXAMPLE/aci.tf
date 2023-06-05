terraform {
  required_providers {
    aci = {
      source = "ciscodevnet/aci"
      version = "0.7.1"
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

module "aciTenant_One" {
  source = "./MODS/"
  for_each = toset( ["Tenant-A", "Tenant-B", "Tenant-C", "Tenant-D"] )
  tenantName = each.key
  tenantDescr = "tenant created by a module"
  vrfName = "vrf1"
  vrfDescr = "vrf created by a module"
  bdName = "bd1"
  bdDescr = "bd created by a module"
  bdSubnet = "10.10.10.1/24"
}


