################################################################################
# VPC
################################################################################

resource "aws_vpc" "myVPC" {
  cidr_block                       = var.cidr
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  tags = {
    Name = "myVPC"
  }
}

###############################################################################
# Internet Gateway
###############################################################################

resource "aws_internet_gateway" "myIGW" {

  vpc_id = aws_vpc.myVPC.id
  tags = {
    Name = "myIGW"
  }
}

################################################################################
# Public subnet
################################################################################

resource "aws_subnet" "public_subnet" {
  vpc_id                          = aws_vpc.myVPC.id
  cidr_block                      = var.public_subnet_cidr_1
  availability_zone               = data.aws_availability_zones.available_1.names[0]
  map_public_ip_on_launch         = var.map_public_ip_on_launch

  tags = {
   Name = "public_subnet"
  }
}


################################################################################
# Publiс routes
################################################################################

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.myVPC.id
  tags = {
    Name = "public_route_table"
  }
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.myIGW.id
}


################################################################################
# Route table association with subnets
################################################################################

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

###############################################################################
# Security Group
###############################################################################

resource "aws_security_group" "SG" {
  name        = "tcw_security_group"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "http"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "ssh"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "https"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Outbound rule"
    }
    tags = {
    Name = "SG"
  }
}
###########################################################################
# NETWORK INTERFACE $ ELASTIC-IP
###############################################################################
resource "aws_network_interface" "ENI" { 
  subnet_id   = aws_subnet.public_subnet.id
  
  tags = {
    Name = "ENI"
  }
}

resource "aws_eip" "EIP" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.ENI.id
  tags = {
    Name = "EIP"
  }

}
###########################################################################
# EC2 instance
##########################################################################
resource "aws_instance" "terraform-hands-on" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  network_interface {
    network_interface_id = aws_network_interface.ENI.id
    device_index         = 0
  }

  tags = {
    Name = "agent-terraform"
  }
}