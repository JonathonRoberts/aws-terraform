variable AWS_SSH_KEY {}
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
}
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}
resource "aws_instance" "web" {
  ami = "${lookup(var.amis, var.region)}"
  availability_zone = "eu-west-2a"
  instance_type = "t2.micro"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.web.id}"]
  subnet_id = "${aws_subnet.eu-west-2a-public.id}"
  associate_public_ip_address = true
  source_dest_check = false
  connection {
    user = "admin"
    private_key = var.AWS_SSH_KEY
    host = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install nginx -y",
      "sudo sysctl enable nginx",
      "sudo service nginx start"
    ]
   }
}
resource "aws_eip" "web" {
  instance = "${aws_instance.web.id}"
  vpc = true
}
resource "aws_subnet" "eu-west-2a-public" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "eu-west-2a"
}

resource "aws_route_table" "eu-west-2-public" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
}

resource "aws_route_table_association" "eu-west-2-public" {
  subnet_id = "${aws_subnet.eu-west-2a-public.id}"
  route_table_id = "${aws_route_table.eu-west-2-public.id}"
}

resource "aws_security_group" "web" {
  name = "vpc_web"
  description = "Allow incoming HTTP connections."
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port = -1
      to_port = -1
      protocol = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port = 0
      to_port = 0
      protocol = -1
      cidr_blocks = ["0.0.0.0/0"]
    }
    vpc_id = "${aws_vpc.default.id}"
}
resource "aws_elb" "web" {
  name = "lbwebsite"
  subnets = ["${aws_subnet.eu-west-2a-public.id}"]
  security_groups = ["${aws_security_group.web.id}"]
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  instances = ["${aws_instance.web.id}"]
}
