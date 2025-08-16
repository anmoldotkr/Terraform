
# ----------------------
# 1. vpc , subnet's , route table and igw (Done)
# 2. key pair. (Done)
# 3. EC2. (Done)
# ------------------------

# VPC
resource "aws_vpc" "my_test_vpc" {
    cidr_block = var.cidr_block
    tags = {
      Name = var.vpc_name
    }
}

# IGW
resource "aws_internet_gateway" "my_test_igw" {
    vpc_id = aws_vpc.my_test_vpc.id
    tags = {
        Name = var.igw
    }
}


# Public subnet's
resource "aws_subnet" "my_pulbic_subnet" {
  vpc_id = aws_vpc.my_test_vpc.id  # interpolation
  count = length(var.public_subnet)
  cidr_block = element(var.public_subnet, count.index)
  availability_zone = element(var.azs,count.index)

  tags = {
    Name = "publicSubnet ${count.index +1}"
  }
}

# Private Subnet
resource "aws_subnet" "my_private_subnet" {
  vpc_id = aws_vpc.my_test_vpc.id
  count = length(var.private_subnet)
  cidr_block = element(var.private_subnet,count.index)
  availability_zone = element(var.azs,count.index)
  tags = {
    Name = "privateSubnet ${count.index + 1}"
  }
}

# Public Route Table
resource "aws_route_table" "my_pulbic_route_table" {
  vpc_id = aws_vpc.my_test_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_test_igw.id
    }

    tags = {
      Name = "my_public_route_table"
    }
}


# Associate public subnet to public route table
resource "aws_route_table_association" "public_rt_association" {

    route_table_id = aws_route_table.my_pulbic_route_table.id
    count = length(var.public_subnet)
    subnet_id = aws_subnet.my_pulbic_subnet[count.index].id
}

# Private Route Table (no internet access)
resource "aws_route_table" "my_private_route_table" {
  vpc_id = aws_vpc.my_test_vpc.id

  tags = {
    Name = "my_private_route_table"
  }
}

# Associate private subnet to private route table
resource "aws_route_table_association" "private_rt_association" {
  route_table_id = aws_route_table.my_private_route_table.id
  count = length(var.private_subnet)
  subnet_id = aws_subnet.my_private_subnet[count.index].id
}


# creating key pair
resource "aws_key_pair" "testkey" {
  key_name = "test-ec2"
  public_key = file("test-ec2.pub")
}

# creating SG for ec2
resource "aws_security_group" "test-sg" {
  name = "Allow security groups"
  vpc_id = aws_vpc.my_test_vpc.id

  ingress  {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress  {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress  {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress  {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-security-group"
  }
}

resource "aws_instance" "my-test-ec2-insta" {
  subnet_id = aws_subnet.my_pulbic_subnet[0].id
  key_name = aws_key_pair.testkey.key_name

  vpc_security_group_ids = [aws_security_group.test-sg.id]

  instance_type = var.instance_type
  ami = var.ami_id
  associate_public_ip_address = true
  tags = {
    "Name" = var.instance_name
  }

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
    encrypted = true

    tags = {
      "Name" = "my-test-vol"
    }
  }
}
