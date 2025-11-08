# AWS Homelab Tesla - David Njoku
# Déploiement simple EC2 t3.micro + VPC + Security Group + Key Pair
# Testé et validé le 08/11/2025

provider "aws" {
  region = var.aws_region
}

# VPC dédié pour le homelab Tesla
resource "aws_vpc" "tesla_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tesla-homelab-vpc"
    Owner = "David Njoku"
  }
}

# Subnet public
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.tesla_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "tesla-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.tesla_vpc.id
  tags = {
    Name = "tesla-igw"
  }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.tesla_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "tesla-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group - SSH + HTTP + tout outbound
resource "aws_security_group" "tesla_sg" {
  name        = "tesla-homelab-sg"
  description = "SG pour homelab Tesla - David Njoku"
  vpc_id      = aws_vpc.tesla_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tesla-sg"
  }
}

# EC2 t3.micro Ubuntu 22.04
resource "aws_instance" "tesla_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Ubuntu 22.04 LTS eu-west-3 (change si autre région)
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.tesla_sg.id]
  key_name      = "tesla-homelab-key" # crée la clé dans AWS console avant

  tags = {
    Name = "tesla-homelab-ec2-david-njoku"
    Mission = "Tesla Acceleration"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update && apt upgrade -y
              apt install nginx -y
              echo "<h1>Homelab Tesla - David Njoku @ $(hostname)</h1>" > /var/www/html/index.html
              systemctl restart nginx
              EOF
}

# Output IP publique
output "tesla_instance_public_ip" {
  value = aws_instance.tesla_server.public_ip
  description = "IP publique de l'instance Tesla Homelab"
}
