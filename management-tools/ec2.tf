provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}


provider "local" {}
# Read the local SSH public key
data "local_file" "ssh_public_key" {
  filename = "/Users/pawankumar/.ssh/my-key-pair.pub"
}

# Create an AWS EC2 key pair
resource "aws_key_pair" "devops-key" {
  key_name   = "my-key-pair"  # Name for the key pair in AWS
  public_key = data.local_file.ssh_public_key.content
}

# Reference the existing VPC
data "aws_vpc" "existing_vpc" {
  id = var.vpc_cidr  # Replace with your VPC ID
}
/*
# Allocate an Elastic IP
resource "aws_eip" "my_eip" {
  instance = aws_instance.my_instance.id
}*/

# Create EC2 Instance in the selected public subnet
resource "aws_instance" "my_instance" {
  ami           = var.amiid  # Replace with the appropriate Ubuntu AMI ID
  instance_type = var.instance_type
  key_name      = aws_key_pair.devops-key.key_name

  associate_public_ip_address = true
  subnet_id     = var.public_sub[0]
  vpc_security_group_ids = [
    aws_security_group.instance_sg.id
  ]

  tags = {
    Name = "Vault-Jenkins-Instance"
  }
}
/*
# Associate the Elastic IP with the EC2 instance
resource "aws_eip_association" "my_eip_association" {
  instance_id  = aws_instance.my_instance.id
  allocation_id = aws_eip.my_eip.id
}*/

# Attach an existing EBS volume to the instance
resource "aws_volume_attachment" "jenkins_vol_attach" {
  device_name = "/dev/xvdf"                # Device name
  volume_id   = var.jenkins_volume_id          # EBS Volume ID
  instance_id = aws_instance.my_instance.id    # Instance ID

  # Wait until the instance is running before attaching the volume
  skip_destroy = true                      # To prevent Terraform from detaching the volume on destroy
}
# Attach an existing EBS volume to the instance
resource "aws_volume_attachment" "vault_vol_attach" {
  device_name = "/dev/xvdg"                # Device name
  volume_id   = var.vault_volume_id         # EBS Volume ID
  instance_id = aws_instance.my_instance.id    # Instance ID

  # Wait until the instance is running before attaching the volume
  skip_destroy = true                      # To prevent Terraform from detaching the volume on destroy
}

# Ensure the volume attachment completes before running user_data
resource "null_resource" "wait_for_volume" {
  depends_on = [aws_volume_attachment.jenkins_vol_attach]

  provisioner "file" {
    source      = "install_vault_jenkins.sh"             # Path to your local script file
    destination = "/tmp/install_vault_jenkins.sh"        # Path on the EC2 instance

    connection {
      type        = "ssh"
      user        = "ubuntu" # Replace with the appropriate user for your AMI
      host        = aws_instance.my_instance.public_ip
      private_key = file("~/.ssh/my-key-pair") # Replace with the path to your SSH private key
    }
  } 
provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_vault_jenkins.sh",
      "/tmp/install_vault_jenkins.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu" # Replace with the appropriate user for your AMI
      host        = aws_instance.my_instance.public_ip
      private_key = file("~/.ssh/my-key-pair") # Replace with the path to your SSH private key
    }
  }

}



