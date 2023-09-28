resource "oci_core_instance" "pipelineboy-master-node" {
  compartment_id      = oci_identity_compartment.pipelineboy.id
  availability_domain = var.availability_domain
  display_name        = "pipelineboy-master-node"
  shape               = "VM.Standard.A1.Flex"
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
    hostname_label   = "master-node"
    nsg_ids = [
      oci_core_network_security_group.pipelineboy-nsg.id,
    ]
    private_ip   = var.master_node_private_ip
    subnet_id    = oci_core_subnet.pipelineboy-subnet-root.id
    display_name = "pipelineboy-master-vnic"
  }

  connection {
    agent       = false
    host        = self.public_ip
    user        = var.instance_user
    private_key = file("./.ssh/pipelineboy.key")
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/scripts",
    ]
  }

  provisioner "file" {
    source      = "./../scripts/cluster/"
    destination = "/home/ubuntu/scripts"
  }

  provisioner "file" {
    source      = "./.ssh/pipelineboy.key"
    destination = "/home/ubuntu/scripts/.key"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install dos2unix -y",
      "find /home/ubuntu/scripts -type f -exec dos2unix {} \\;",
      "find /home/ubuntu/scripts -type f -exec chmod +x {} \\;",
      "sudo bash /home/ubuntu/scripts/install_k8s.sh",
      "sudo kubeadm init --apiserver-advertise-address=${self.private_ip}",
      "sudo bash /home/ubuntu/scripts/get_join_command.sh ${self.private_ip}",
      "chmod 600 /home/ubuntu/scripts/.key",
      "sudo update-alternatives --set iptables /usr/sbin/iptables-legacy",
      "sudo iptables -I INPUT -p tcp -j ACCEPT",
      "sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null",
      "sudo cp /etc/kubernetes/admin.conf /home/ubuntu/scripts/config",
      "sudo chmod 666 /home/ubuntu/scripts/config",
      "sudo bash /home/ubuntu/scripts/kubeconfig.sh",
      "sudo systemctl reboot"
    ]
  }
}

output "pipelineboy-public-address-master-node" {
  value = oci_core_instance.pipelineboy-master-node.public_ip
}

resource "oci_core_instance" "pipelineboy-worker-node" {
  count               = 2
  compartment_id      = oci_identity_compartment.pipelineboy.id
  availability_domain = var.availability_domain
  display_name        = "pipelineboy-worker-node-${count.index + 1}"
  shape               = "VM.Standard.A1.Flex"
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
    hostname_label   = "worker-node-${count.index + 1}"
    nsg_ids = [
      oci_core_network_security_group.pipelineboy-nsg.id,
    ]
    subnet_id    = oci_core_subnet.pipelineboy-subnet-root.id
    display_name = "pipelineboy-worker-node-${count.index + 1}-vnic"
  }

  connection {
    agent       = false
    host        = self.public_ip
    user        = var.instance_user
    private_key = file("./.ssh/pipelineboy.key")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo update-alternatives --set iptables /usr/sbin/iptables-legacy",
      "sudo iptables -I INPUT -p tcp -j ACCEPT",
      "sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null",
      "sudo systemctl reboot"
    ]
  }
}

resource "time_sleep" "waiting-before-cluster-config" {
  depends_on = [oci_core_instance.pipelineboy-worker-node, oci_core_instance.pipelineboy-master-node]
  create_duration = "120s"
}

locals {
  create_folder_commands      = [for ip in oci_core_instance.pipelineboy-worker-node.*.private_ip : "ssh -i /home/ubuntu/scripts/.key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${ip} 'mkdir -p /home/ubuntu/scripts'"]
  set_perm_folder_commands    = [for ip in oci_core_instance.pipelineboy-worker-node.*.private_ip : "ssh -i /home/ubuntu/scripts/.key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${ip} 'sudo chmod 777 /home/ubuntu/scripts'"]
  scp_commands                = [for ip in oci_core_instance.pipelineboy-worker-node.*.private_ip : "scp -i /home/ubuntu/scripts/.key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /home/ubuntu/scripts ubuntu@${ip}:/home/ubuntu"]
  install_commands            = [for ip in oci_core_instance.pipelineboy-worker-node.*.private_ip : "ssh -i /home/ubuntu/scripts/.key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${ip} 'sudo bash /home/ubuntu/scripts/install_k8s.sh'"]
  join_commands               = [for ip in oci_core_instance.pipelineboy-worker-node.*.private_ip : "ssh -i /home/ubuntu/scripts/.key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${ip} 'sudo bash /home/ubuntu/scripts/join_cluster.sh'"]
  kubeconfig_commands         = [for ip in oci_core_instance.pipelineboy-worker-node.*.private_ip : "ssh -i /home/ubuntu/scripts/.key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${ip} 'sudo bash /home/ubuntu/scripts/kubeconfig.sh'"]
  delete_config_file_commands = [for ip in oci_core_instance.pipelineboy-worker-node.*.private_ip : "ssh -i /home/ubuntu/scripts/.key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${ip} 'sudo rm -rf /home/ubuntu/scripts'"]
}

resource "null_resource" "cluster-config" {
  depends_on = [time_sleep.waiting-before-cluster-config]
  connection {
    agent       = false
    host        = oci_core_instance.pipelineboy-master-node.public_ip
    user        = var.instance_user
    private_key = file("./.ssh/pipelineboy.key")
  }
  provisioner "remote-exec" {
    inline = local.create_folder_commands
  }
  provisioner "remote-exec" {
    inline = local.set_perm_folder_commands
  }
  provisioner "remote-exec" {
    inline = local.scp_commands
  }
  provisioner "remote-exec" {
    inline = local.install_commands
  }
  provisioner "remote-exec" {
    inline = local.join_commands
  }
  provisioner "remote-exec" {
    inline = local.kubeconfig_commands
  }
  provisioner "remote-exec" {
    inline = local.delete_config_file_commands
  }
  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /home/ubuntu/scripts",
      "kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml"
    ]
  }
}