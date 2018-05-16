resource "aws_instance" "example" {
  ami           = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo ${aws_instance.example.private_ip} >> private_ips.txt"
  }
}

output "ip" {
  value = "${aws_instance.example.public_ip}"
}

# Creating VPC

resource "aws_vpc" "My_Vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags {
    Name = "VPC_Main"
  }
}
