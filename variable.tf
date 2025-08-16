# VPC Configuration
variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "my-test-vpc"
}

# Internet Gateway
variable "igw" {
  description = "Name tag for the Internet Gateway"
  type        = string
  default     = "my-test-igw"
}

# Availability Zones
variable "azs" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]  # Change based on your region
}

# Public Subnets
variable "public_subnet" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# Private Subnets
variable "private_subnet" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# Key Pair Configuration
variable "key_name" {
  description = "Name for the AWS key pair"
  type        = string
  default     = "test-ec2"
}

variable "public_key_path" {
  description = "Path to the public key file"
  type        = string
  default     = "test-ec2.pub"
}

# ec2 config
variable "instance_type" {
  description = "Ec2 instance type"
  type = string
  default = "t2.micro"
}

variable "instance_name" {
    description = "EC2 instance name"
    type = string
    default = "test-ec2-server"
}

variable "ami_id" {
    description = "AMI_ID"
    type = string
    default = "ami-05f991c49d264708f" 
}