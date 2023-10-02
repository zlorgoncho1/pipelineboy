terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "=5.12.0"
    }
  }
}

provider "oci" {
  auth             = var.provider_auth
  tenancy_ocid     = var.provider_tenancy_ocid
  user_ocid        = var.provider_user_ocid
  fingerprint      = var.provider_fingerprint
  private_key_path = var.provider_private_key_path
  region           = var.provider_region
}

resource "oci_identity_compartment" "pipelineboy" {
  description = "pipelineboy"
  name        = "pipelineboy"
}