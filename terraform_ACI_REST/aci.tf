terraform {
  required_providers {
    aci = {
      source = "ciscodevnet/aci"
    }
  }
}

provider "aci" {
  username    = var.aciUser
  private_key = var.aciPrivateKey
  cert_name   = var.aciCertName
  insecure    = true
  url         = var.aciUrl
}

resource "aci_rest" "restotest" {
  path    = "/api/mo/uni.json"
  payload = <<EOF
  {
    "fvTenant": 
     {"attributes": 
       {"name": ${var.tenantName},
        "descr": "created with aci_rest in terraform",
        "status": "created"
       }
     }
  }
  EOF
}
