#!/bin/bash

# Variables
JENKINS_VOLUME_ID="vol-03bec1d4618d909e2"  # Replace with your Jenkins EBS Volume ID
VAULT_VOLUME_ID="vol-0beb575b360648c46"    # Replace with your Vault EBS Volume ID
JENKINS_MOUNT_POINT="/mnt/jenkins"
VAULT_MOUNT_POINT="/mnt/vault"

# Update and upgrade system packages
sudo apt-get update -y
sudo apt-get upgrade -y

# Install necessary packages
#sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Install Docker
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y 

##install docker packaes
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

awsavail=$(aws --version)
if [ -z $awsavail ]; then 
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  sudo apt install amazon-ec2-utils -y
fi
# Attach EBS volumes to the instance
INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2)

# Attach Jenkins EBS volume
aws ec2 attach-volume --volume-id $JENKINS_VOLUME_ID --instance-id $INSTANCE_ID --device /dev/sdf
#sudo mkfs -t ext4 /dev/xvdf
sudo mkdir -p $JENKINS_MOUNT_POINT
sudo mount /dev/xvdf $JENKINS_MOUNT_POINT
echo '/dev/xvdf /mnt/jenkins ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab

# Attach Vault EBS volume
aws ec2 attach-volume --volume-id $VAULT_VOLUME_ID --instance-id $INSTANCE_ID --device /dev/sdg
#sudo mkfs -t ext4 /dev/xvdg
sudo mkdir -p $VAULT_MOUNT_POINT
sudo mount /dev/xvdg $VAULT_MOUNT_POINT
echo '/dev/xvdg /mnt/vault ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab

# Pull Jenkins Docker image
sudo docker pull jenkins/jenkins:lts

# Run Jenkins container with EBS volume
sudo chown -R 1000:1000 $JENKINS_MOUNT_POINT
sudo docker run -d --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v $JENKINS_MOUNT_POINT:/var/jenkins_home \
  jenkins/jenkins:lts-jdk17

# Pull Vault Docker image
sudo docker pull hashicorp/vault

# Run Vault container with EBS volume
sudo docker run -d --name vault \
  -p 8200:8200 \
  --cap-add=IPC_LOCK \
  -e 'VAULT_DEV_ROOT_TOKEN_ID=myroot' \
  -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200' \
  -v $VAULT_MOUNT_POINT:/vault/data \
  hashicorp/vault

# Display Jenkins initial admin password
echo "Waiting for Jenkins to start..."
sleep 30
sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# Display Vault access information
echo "Vault is running in development mode."
echo "Access it at http://<your_ec2_public_ip>:8200"
echo "Root token: myroot"

echo "Jenkins is accessible at http://<your_ec2_public_ip>:8080"