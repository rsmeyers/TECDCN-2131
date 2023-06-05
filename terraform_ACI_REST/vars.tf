variable "tenantName" {
  default = "terraform-601"
}
variable "aciUser" {
  default = "ansible"
}
variable "aciPrivateKey" {
  default = "./ansible.key"
}
variable "aciCertName" {
  default = "ansible"
}
variable "aciUrl" {
  default = "https://10.48.168.221"
}

variable "bd_subnet" {
  default = "1.1.1.2/24"
}
variable "provider_profile_dn" {
  default = "uni/vmmp-VMware"
}

variable "vrf_name" {
  default = "vrf1"
}

variable "ap_name" {
  default = "app1"
}

