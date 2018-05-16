
#############################################################
#Public key

resource "aws_key_pair" "terra_key" {
	key_name = "terra_key"
	public_key = "<key.pub>"

}

#====================================================================#

# ec2 Instance creation using public Subnet.
#################################################

resource "aws_instance" "EC2_Public" {
	ami = "ami-b46f48db"
	instance_type = "t2.micro"
	key_name ="${aws_key_pair.terra_key.key_name}"
	tags {
		Name = "Public-Web-Server"
	}
}

########################################

# ELB using private Subnet

########################################


resource "aws_elb" "web-elb" {
  name = "terraform-web-elb"

  subnets         = ["${aws_subnet.ap-south-1a-private.id},{aws_subnet.ap-south-1b-private.id}"]
  security_groups = ["${aws_security_group.elb-securitygroup.id}"]
  instances       = ["${aws_instance.web-elb.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 30
  }

  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 400
  tags {
    Name = "my-elb"
  }
}


resource "aws_instance" "Web_Private" {
	ami = "${lookup(var.amis, var.aws_region")}"
	instance_type = "t2.micro"
	key_name ="${aws_key_pair.terra_key.key_name}"
  	vpc_security_group_ids = ["${aws_security_group.elb-securitygroup.id}"]
	subnet_id = ["${aws_subnet.ap-south-1a-private.id.id}","${aws_subnet.ap-south-1b-private.id.id}"]
	tags {
		Name = "Private-Web-Server"
	}

provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
    ]
  }
}