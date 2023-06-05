resource "aci_vrf" "myvrf" {
  description = var.vrfDescr 
  name        = var.vrfName
  tenant_dn   = aci_tenant.mytenant.id
}

resource "aci_tenant" "mytenant" {
  description = var.tenantDescr
  name        = var.tenantName
}

resource "aci_bridge_domain" "mybd" {
  description = var.bdDescr
  name = var.bdName
  tenant_dn   = aci_tenant.mytenant.id
  relation_fv_rs_ctx = aci_vrf.myvrf.id
}

resource "aci_subnet" "mybdsubnet" {
  parent_dn = aci_bridge_domain.mybd.id
  ip        = var.bdSubnet
}

