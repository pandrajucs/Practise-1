# 3-Public-Servers
resource "aws_instance" "Public-Server" {
  ami                    = var.ami_id
  instance_type          = var.ec2_type
  count                  = 1
  subnet_id              = aws_subnet.Public-Subnet[0].id
  availability_zone      = var.azs[0]
  key_name               = var.key
  vpc_security_group_ids = ["${aws_security_group.My-SG.id}"]
  user_data              = file("script.sh")
  tags = {
    "Name" = "Public-Server-1"
  }
}

# 3-Private Servers
resource "aws_instance" "Private-Server" {
  depends_on = [
    aws_nat_gateway.My-NATGw
  ]
  ami                    = var.ami_id
  instance_type          = var.ec2_type
  count                  = length(var.azs)
  subnet_id              = element(aws_subnet.Private-Subnet[*].id, count.index)
  availability_zone      = element(var.azs, count.index)
  key_name               = var.key
  vpc_security_group_ids = ["${aws_security_group.My-SG.id}"]
  user_data              = file("script.sh")
  tags = {
    "Name" = "Private-Server-${count.index + 1}"
  }
}
