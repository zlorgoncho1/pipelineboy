resource "oci_core_vcn" "pipeline-vcn" {
  cidr_blocks = [
    "1.1.1.0/24",
  ]
  compartment_id = oci_identity_compartment.pipelineboy.id
  display_name   = "pipeline-vcn"
  dns_label      = "pipelineboyvcn"
}

resource "oci_core_subnet" "pipelineboy-subnet-root" {
  cidr_block     = "1.1.1.0/24"
  compartment_id = oci_identity_compartment.pipelineboy.id

  display_name   = "pipelineboy-subnet-root"
  dns_label      = "pipelineboysubn"
  vcn_id         = oci_core_vcn.pipeline-vcn.id
  route_table_id = oci_core_route_table.pipelineboy-rt-default.id
}

resource "oci_core_internet_gateway" "pipelineboy-internet-gateway" {
  compartment_id = oci_identity_compartment.pipelineboy.id
  display_name   = "pipelineboy-internet-gateway"
  vcn_id         = oci_core_vcn.pipeline-vcn.id
}

resource "oci_core_route_table" "pipelineboy-rt-default" {
  compartment_id = oci_identity_compartment.pipelineboy.id
  display_name   = "pipelineboy-route-table-default"
  vcn_id         = oci_core_vcn.pipeline-vcn.id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.pipelineboy-internet-gateway.id
  }
}

resource "oci_core_network_security_group" "pipelineboy-nsg" {
  compartment_id = oci_identity_compartment.pipelineboy.id
  display_name   = "pipelineboy-nsg"
  vcn_id         = oci_core_vcn.pipeline-vcn.id
}

resource "oci_core_network_security_group_security_rule" "pipelineboy-nsg-rule-internal-ingress" {
  network_security_group_id = oci_core_network_security_group.pipelineboy-nsg.id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = "1.1.1.0/24"
  source_type               = "CIDR_BLOCK"
}
