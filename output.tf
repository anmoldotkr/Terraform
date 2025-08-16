output "aws_vpc" {
  value = aws_vpc.my_test_vpc.id
}
output "aws_instance" {
  value = aws_instance.my-test-ec2-insta.public_ip
}

output "aws_internet_gateway" {
  value = aws_internet_gateway.my_test_igw.id
}