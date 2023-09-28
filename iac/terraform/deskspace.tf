resource "oci_core_instance" "pipelineboy-deskspace" {
  compartment_id      = oci_identity_compartment.pipelineboy.id
  availability_domain = var.availability_domain
  display_name        = "pipelineboy-deskspace"
  shape               = var.vm_shape_standard

  shape_config {
    memory_in_gbs = 8
    ocpus         = 4
  }
  metadata = {
    ssh_authorized_keys = file("./.ssh/pipelineboy.pub")
  }
  source_details {
    source_id   = var.ubuntu_22_tls
    source_type = "image"
  }
  create_vnic_details {
    assign_public_ip = "true"
    hostname_label   = "deskspace"
    nsg_ids = [
      oci_core_network_security_group.pipelineboy-nsg.id,
    ]
    private_ip   = var.deskspace_private_ip
    subnet_id    = oci_core_subnet.pipelineboy-subnet-root.id
    display_name = "pipelineboy-deskspace-vnic"
  }

  connection {
    agent       = false
    host        = self.public_ip
    user        = var.instance_user
    private_key = file("./.ssh/pipelineboy.key")
  }

  provisioner "local-exec" {
    command = "python ../scripts/deskspace/copy_infra.py"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/pipelineboy/iac/config",
      "mkdir -p /home/ubuntu/pipelineboy/iac/nginx",
      "mkdir -p /home/ubuntu/pipelineboy/iac/kubernetes",
      "mkdir -p /home/ubuntu/pipelineboy/iac/scripts/deskspace",
      "mkdir -p /home/ubuntu/pipelineboy/iac/terraform/.ssh",
    ]
  }

  provisioner "file" {
    source      = "./../config/"
    destination = "/home/ubuntu/pipelineboy/iac/config"
  }

  provisioner "file" {
    source      = "./../nginx/"
    destination = "/home/ubuntu/pipelineboy/iac/nginx"
  }

  provisioner "file" {
    source      = "./../kubernetes/"
    destination = "/home/ubuntu/pipelineboy/iac/kubernetes"
  }

  provisioner "file" {
    source      = "./../scripts/deskspace/"
    destination = "/home/ubuntu/pipelineboy/iac/scripts/deskspace"
  }

  provisioner "file" {
    source      = "./../infra/"
    destination = "/home/ubuntu/pipelineboy/iac/terraform"
  }

  provisioner "file" {
    source      = "./../terraform/.ssh/"
    destination = "/home/ubuntu/pipelineboy/iac/terraform/.ssh"
  }

  provisioner "file" {
    source      = "./../docker-compose.iac.yml"
    destination = "/home/ubuntu/pipelineboy/iac/docker-compose.iac.yml"
  }

  provisioner "local-exec" {
    command = "python ../scripts/deskspace/delete_infra_folder.py"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install dos2unix -y",
      "dos2unix /home/ubuntu/pipelineboy/iac/scripts/deskspace/config.sh",
      "sudo chmod +x /home/ubuntu/pipelineboy/iac/scripts/deskspace/config.sh",
      "sudo bash /home/ubuntu/pipelineboy/iac/scripts/deskspace/config.sh",
    ]
  }
}

output "pipelineboy-public-address-deskspace" {
  value = oci_core_instance.pipelineboy-deskspace.public_ip
}