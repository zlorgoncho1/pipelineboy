#!/bin/bash
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg openjdk-11-jdk -y
sudo install -m 0755 -d /etc/apt/keyrings -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo chmod +x /home/ubuntu/pipelineboy/iac/scripts/deskspace/kubectl.sh
sudo chmod +x /home/ubuntu/pipelineboy/iac/scripts/deskspace/terraform.sh
sudo mv /home/ubuntu/pipelineboy/iac/scripts/deskspace/kubectl.sh /bin/kubectl
sudo mv /home/ubuntu/pipelineboy/iac/scripts/deskspace/terraform.sh /bin/terraform
sudo dos2unix /bin/terraform
sudo dos2unix /bin/kubectl