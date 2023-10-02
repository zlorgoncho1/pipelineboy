# FOR PROVIDERS - LOADED FROM config.auto.tfvars
variable "provider_auth" {}
variable "provider_tenancy_ocid" {}
variable "provider_user_ocid" {}
variable "provider_fingerprint" {}
variable "provider_private_key_path" {}
variable "provider_region" {}

# VM CONFIG
variable "availability_domain" {
  default = "rFLd:EU-FRANKFURT-1-AD-1"
}

# UBUNTU 22 IMAGES
variable "ubuntu_22_tls" {
  default = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaawakxkhuwx7flufdsjeuu42hxzxnaeeajqq4ohfqprw3s6zl7bgcq"
}

# FOR DESKPACE
variable "deskspace_private_ip" {
  default = "1.1.1.10"
}

variable "master_node_private_ip" {
  default = "1.1.1.20"
}

# SHAPE
variable "vm_shape_standard" {
  default = "VM.Standard.A1.Flex"
}


# INSTANCE USER
variable "instance_user" {

}