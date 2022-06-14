terraform {
  required_providers {
    aci = {
      source = "ciscodevnet/aci"
    }
  }
  required_version = ">= 0.13"
}

provider "aci" {
  username    = var.aciUser
  private_key = var.aciPrivateKey
  cert_name   = var.aciCertName
  insecure    = true
  url         = var.aciUrl
}

resource "aci_vrf" "vrf1" {
  tenant_dn              = aci_tenant.demo.id
  name                   = var.vrf_name
  bd_enforced_enable     = "yes"
  ip_data_plane_learning = "enabled"
  knw_mcast_act          = "permit"
  pc_enf_pref            = "enforced"
}

resource "aci_bridge_domain" "bdmgmt" {
  tenant_dn          = aci_tenant.demo.id
  relation_fv_rs_ctx = aci_vrf.vrf1.id
  name               = var.bdmgmt_name
  description        = var.bdmgmt_desc
}

resource "aci_bridge_domain" "bd1" {
  tenant_dn                = aci_tenant.demo.id
  relation_fv_rs_ctx       = aci_vrf.vrf1.id
  name                     = var.bd1_name
  description              = var.bd1_desc
  relation_fv_rs_bd_to_out = [data.aci_l3_outside.internet.id]
}

resource "aci_bridge_domain" "bd2" {
  tenant_dn                = aci_tenant.demo.id
  relation_fv_rs_ctx       = aci_vrf.vrf1.id
  name                     = var.bd2_name
  description              = var.bd2_desc
  relation_fv_rs_bd_to_out = [data.aci_l3_outside.internet.id]
}


resource "aci_tenant" "demo" {
  name        = var.tenantName
  description = var.tenant_desc
}

resource "aci_subnet" "bdmgmt_subnet" {
  parent_dn = aci_bridge_domain.bdmgmt.id
  ip        = var.bdmgmt_subnet
}

resource "aci_subnet" "bd1_subnet" {
  parent_dn = aci_bridge_domain.bd1.id
  ip        = var.bd1_subnet
  scope     = ["public", "shared"]
}

resource "aci_subnet" "bd2_subnet" {
  parent_dn = aci_bridge_domain.bd2.id
  ip        = var.bd2_subnet
  scope     = ["public", "shared"]
}

resource "aci_application_profile" "app1" {
  tenant_dn = aci_tenant.demo.id
  name      = var.ap_name
}

data "aci_vmm_domain" "vds" {
  provider_profile_dn = var.provider_profile_dn
  name                = var.dvs_name
}

resource "aci_application_epg" "epgmgmt" {
  application_profile_dn = aci_application_profile.app1.id
  name                   = var.epgmgmt_name
  relation_fv_rs_bd      = aci_bridge_domain.bdmgmt.id
  relation_fv_rs_cons    = [aci_contract.contract_ssh.id, aci_contract.contract_icmp.id, data.aci_contract.commondefault.id]
  relation_fv_rs_prov    = [aci_contract.contract_git.id]
}

resource "aci_application_epg" "epg1" {
  application_profile_dn = aci_application_profile.app1.id
  name                   = var.epg1_name
  relation_fv_rs_bd      = aci_bridge_domain.bd1.id
  relation_fv_rs_cons    = [aci_contract.contract_epg1_epg2.id, data.aci_contract.commondefault.id, aci_contract.contract_icmp.id]
  relation_fv_rs_prov    = [aci_contract.contract_ssh.id, aci_contract.contract_icmp.id]
}

resource "aci_application_epg" "epg2" {
  application_profile_dn = aci_application_profile.app1.id
  name                   = var.epg2_name
  relation_fv_rs_bd      = aci_bridge_domain.bd2.id
  relation_fv_rs_prov    = [aci_contract.contract_epg1_epg2.id, aci_contract.contract_ssh.id, aci_contract.contract_icmp.id]
  relation_fv_rs_cons    = [aci_contract.contract_git.id, data.aci_contract.commondefault.id, aci_contract.contract_icmp.id]
}

data "aci_physical_domain" "vmnic6" {
  name = "ESXi_10.48.168.40_vmnic6"
}

resource "aci_epg_to_domain" "mgmt" {
  application_epg_dn = aci_application_epg.epgmgmt.id
  tdn                = data.aci_physical_domain.vmnic6.id
  instr_imedcy       = "immediate"
}

resource "aci_epg_to_static_path" "vlan45" {
  application_epg_dn = aci_application_epg.epgmgmt.id
  tdn                = "topology/pod-1/paths-102/pathep-[eth1/24]"
  encap              = "vlan-45"
  mode               = "regular"
}

resource "aci_epg_to_domain" "epg1" {
  application_epg_dn    = aci_application_epg.epg1.id
  tdn                   = data.aci_vmm_domain.vds.id
  vmm_allow_promiscuous = "accept"
  vmm_forged_transmits  = "accept"
  vmm_mac_changes       = "accept"
  instr_imedcy          = "immediate"
  res_imedcy            = "pre-provision"
}

resource "aci_epg_to_domain" "epg2" {
  application_epg_dn    = aci_application_epg.epg2.id
  tdn                   = data.aci_vmm_domain.vds.id
  vmm_allow_promiscuous = "accept"
  vmm_forged_transmits  = "accept"
  vmm_mac_changes       = "accept"
  instr_imedcy          = "immediate"
  res_imedcy            = "pre-provision"
}


data "aci_tenant" "common" {
  name = "common"
}

data "aci_contract" "commondefault" {
  tenant_dn = data.aci_tenant.common.id
  name      = "default"
}

data "aci_l3_outside" "internet" {
  tenant_dn = data.aci_tenant.common.id
  name      = "Internet"
}

resource "aci_contract" "contract_epg1_epg2" {
  tenant_dn = aci_tenant.demo.id
  name      = "Web"
}

resource "aci_contract" "contract_git" {
  tenant_dn = aci_tenant.demo.id
  name      = "Git"
}

resource "aci_contract" "contract_ssh" {
  tenant_dn = aci_tenant.demo.id
  name      = "SSH"
}

resource "aci_contract" "contract_icmp" {
  tenant_dn = aci_tenant.demo.id
  name      = "ICMP"
}

resource "aci_contract_subject" "Web_subject1" {
  contract_dn                  = aci_contract.contract_epg1_epg2.id
  name                         = "Web_Subject"
  relation_vz_rs_subj_filt_att = [aci_filter.allow_https.id, aci_filter.allow_http.id]
}

resource "aci_contract_subject" "Git_subject1" {
  contract_dn                  = aci_contract.contract_git.id
  name                         = "Git_Subject"
  relation_vz_rs_subj_filt_att = [aci_filter.allow_git.id]
}

resource "aci_contract_subject" "SSH_subject1" {
  contract_dn                  = aci_contract.contract_ssh.id
  name                         = "SSH_Subject"
  relation_vz_rs_subj_filt_att = [aci_filter.allow_ssh.id]
}

resource "aci_contract_subject" "ICMP_subject1" {
  contract_dn                  = aci_contract.contract_icmp.id
  name                         = "ICMP_Subject"
  relation_vz_rs_subj_filt_att = [aci_filter.allow_icmp.id]
}

resource "aci_filter" "allow_https" {
  tenant_dn = aci_tenant.demo.id
  name      = "allow_https"
}

resource "aci_filter" "allow_git" {
  tenant_dn = aci_tenant.demo.id
  name      = "allow_git"
}

resource "aci_filter" "allow_icmp" {
  tenant_dn = aci_tenant.demo.id
  name      = "allow_icmp"
}

resource "aci_filter" "allow_http" {
  tenant_dn = aci_tenant.demo.id
  name      = "allow_http"
}

resource "aci_filter" "allow_mysql" {
  tenant_dn = aci_tenant.demo.id
  name      = "allow_mysql"
}

resource "aci_filter" "allow_ssh" {
  tenant_dn = aci_tenant.demo.id
  name      = "allow_ssh"
}

resource "aci_filter" "allow_rdp" {
  tenant_dn = aci_tenant.demo.id
  name      = "allow_rdp"
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

resource "aci_filter_entry" "git" {
  name        = "git"
  filter_dn   = aci_filter.allow_git.id
  ether_t     = "ip"
  prot        = "tcp"
  d_from_port = "https"
  d_to_port   = "https"
  stateful    = "yes"
}


resource "aci_filter_entry" "icmp" {
  name      = "icmp"
  filter_dn = aci_filter.allow_icmp.id
  ether_t   = "ip"
  prot      = "icmp"
  stateful  = "yes"
}

resource "aci_filter_entry" "http" {
  name        = "http"
  filter_dn   = aci_filter.allow_http.id
  ether_t     = "ip"
  prot        = "tcp"
  d_from_port = "80"
  d_to_port   = "80"
  stateful    = "yes"
}

resource "aci_filter_entry" "mysql" {
  name        = "http"
  filter_dn   = aci_filter.allow_mysql.id
  ether_t     = "ip"
  prot        = "tcp"
  d_from_port = "3306"
  d_to_port   = "3306"
  stateful    = "yes"
}

resource "aci_filter_entry" "ssh" {
  name        = "http"
  filter_dn   = aci_filter.allow_ssh.id
  ether_t     = "ip"
  prot        = "tcp"
  d_from_port = "22"
  d_to_port   = "22"
  stateful    = "yes"
}

resource "aci_filter_entry" "rdp" {
  name        = "http"
  filter_dn   = aci_filter.allow_rdp.id
  ether_t     = "ip"
  prot        = "tcp"
  d_from_port = "3389"
  d_to_port   = "3389"
  stateful    = "yes"
}


