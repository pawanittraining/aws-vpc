# Create Security Group for Jenkins and Vault
resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "Allow inbound traffic for Jenkins and Vault"
  vpc_id      = data.aws_vpc.existing_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["103.217.133.95/32"]  # Allow access from anywhere; restrict as needed
  }

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["103.217.133.95/32"]  # Allow access from anywhere; restrict as needed
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["103.217.133.95/32"]  # Allow access from anywhere; restrict as needed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["103.217.133.95/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow outbound traffic
  }

  tags = {
    Name = "instance_sg"
  }
}