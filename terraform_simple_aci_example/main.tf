terraform {
   required_providers {
      aci = {
         source = "CiscoDevNet/aci"
      }
   }
}



provider "aci" {
  username = var.aciUser
  password = var.aciPassword
  insecure = true
  url = var.aciUrl
}


resource "aci_tenant" "demo" {
  name = var.tenantName
  description = "created by terraform2"
}

resource "aci_vrf" "vrf1" {
  tenant_dn = aci_tenant.demo.id
  name      = "vrf1"
}

resource "aci_bridge_domain" "bd1" {
  tenant_dn          = aci_tenant.demo.id
  relation_fv_rs_ctx = aci_vrf.vrf1.id
  name               = "bd2"
}

resource "aci_subnet" "bd1_subnet" {
  parent_dn = aci_bridge_domain.bd1.id
  ip               = "42.42.42.1/24"
}
resource "aci_subnet" "bd1_subnet2" {
  parent_dn = aci_bridge_domain.bd1.id
  ip               = "42.42.43.1/24"
}

resource "aci_application_profile" "app1" {
  tenant_dn = aci_tenant.demo.id
  name      = "app1"
}

resource "aci_application_profile" "app2" {
  tenant_dn = aci_tenant.demo.id
  name      = "app2"
}

#data "aci_vmm_domain" "vds" {
#  provider_profile_dn = var.provider_profile_dn
#  name                = "VMware"
#}

#resource "aci_application_epg" "epg1" {
#  application_profile_dn = aci_application_profile.app1.id
#  name                   = "epg1"
#  relation_fv_rs_bd      = aci_bridge_domain.bd1.name
#  relation_fv_rs_dom_att = ["${data.aci_vmm_domain.vds.id}"]
#  relation_fv_rs_cons    = ["${aci_contract.contract_epg1_epg2.name}"]
#}


#resource "aci_application_epg" "epg2" {
#  application_profile_dn = aci_application_profile.app1.id
#  name                   = "epg2"
#  relation_fv_rs_bd      = aci_bridge_domain.bd1.name
#  relation_fv_rs_dom_att = ["${data.aci_vmm_domain.vds.id}"]
#  relation_fv_rs_prov    = ["${aci_contract.contract_epg1_epg2.name}"]
#}

resource "aci_contract" "contract_epg1_epg2" {
  tenant_dn = aci_tenant.demo.id
  name      = "Web"
}

resource "aci_contract_subject" "Web_subject1" {
  contract_dn                  = aci_contract.contract_epg1_epg2.id
  name                         = "Subject"
  relation_vz_rs_subj_filt_att = ["${aci_filter.allow_https.id}","${aci_filter.allow_icmp.id}"]
}

resource "aci_filter" "allow_https" {
  tenant_dn = aci_tenant.demo.id
  name      = "allow_https"
}
resource "aci_filter" "allow_icmp" {
  tenant_dn = aci_tenant.demo.id
  name      = "allow_icmp"
}

resource "aci_filter_entry" "https" {
  name        = "https"
  filter_dn   = aci_filter.allow_https.id
  ether_t     = "ip"
  prot        = "tcp"
  d_from_port = "https"
  d_to_port   = "https"
  stateful    = "yes"
}

#resource "aci_filter_entry" "icmp" {
#  name        = "icmp"
#  filter_dn   = aci_filter.allow_icmp.id
#  ether_t     = "ip"
#  prot        = "icmp"
#  stateful    = "yes"
#}


#resource "aci_rest" "Tenant_aci_rest" {
#  path       = "/api/node/mo/uni/tn-test01.json"
#  class_name = "fvTenant"
#
#  content = {
#    "name" = "test01"
#  }
#}
