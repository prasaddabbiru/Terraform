# Creating VPC

resource "aws_vpc" "My_Vpc" {
	cidr_block = "${var.vpc_cidr}"
	enable_dns_hostnames = true
	instance_tenancy = "default"
	tags {
		Name = "VPC_Main"
		}
}

#Creating Internet Gateway#

resource "aws_internet_gateway" "igw" {
	vpc_id = "${aws_vpc.default.id}"
	}

#Creating Public Subnet

resource "aws_subnet" "ap-south-1a-public" {
	vpc_id = "${aws_vpc.My_Vpc.id}"
	cidr_block = "${var.public_subnet_cidr}"
	availability_zone = "${length(data.availability_zones.azs.names)}"

	tags {
		Name = "Public-Subnet-1a"
		}
}

resource "aws_subnet" "ap-south-1b-public" {
	vpc_id = "${aws_vpc.My_Vpc.id}"
	cidr_block = "${var.public_subnet_cidr}"
	availability_zone = "${length(data.availability_zones.azs.names)}"

	tags {
		Name = "Public-Subnet-1b"
		}
}

## Creating Route table and associating the IGW to make the subnet public access to the internet

resource "aws_route_table" "ap-south-1a-public" {
	vpc_id ="${aws_vpc.My_Vpc.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.igw.id}"
	}

	tags{
		Name = "Public Subnet"
	}
}

resource "aws_route_table_association" "ap-south-1a-public" {
	subnet_id = "${aws_subnet.ap-south-1a-public.id}"
	route_table_id = "${aws_route_table.ap-south-1a-public.id}"

}

################
#Private Subnet#
################

resource "aws_subnet" "ap-south-1a-private" {
	vpc_id = "${aws_vpc.My_Vpc.id}"
	cidr_block = "${var.private_subnet_cidr}"
	availability_zone = "${length(data.availability_zones.azs.names)}"
	tags {
		Name = "Private-Subnet-1a"
		}
}

resource "aws_subnet" "ap-south-1b-private" {
	vpc_id = "${aws_vpc.My_Vpc.id}"
	cidr_block = "${var.private_subnet_cidr}"
	availability_zone = "${length(data.availability_zones.azs.names)}"
	tags {
		Name = "Private-Subnet-1b"
		}
}


###################
#   NAT Gateway   #
###################

resource "aws_eip" "eip_nat" {
  vpc      = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.eip_nat.id}"
  subnet_id     = "${aws_subnet.ap-south-1a-public.id}"
}

###############################################################################################
#  Create Route Table and NAT gateway to communicate with internet via public subnet          #
###############################################################################################

resource "aws_route_table" "ap-south-1a-private" {
	vpc_id ="${aws_vpc.My_Vpc.id}"

	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = "${aws_nat_gateway.nat_gw.id}
	}

	tags{
		Name = "Private-Route"
	}
}

resource "aws_route_table_association" "ap-south-1a-private" {
	subnet_id = "${aws_subnet.ap-south-1a-private.id}"
	route_table_id = "${aws_route_table.ap-south-1a-private.id}"

}
