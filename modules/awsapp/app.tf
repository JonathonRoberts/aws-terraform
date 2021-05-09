resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
}
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}
resource "aws_security_group" "app" {
  name = "vpc_app"
  description = "Allow traffic to pass from the private subnet to the internet"
  ingress {
    from_port = 22
    to_port = 22
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
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  egress {
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
resource "aws_iam_instance_profile" "s3_profile" {
  name = "s3_profile"
  role = "${aws_iam_role.s3_role.name}"
}
resource "aws_subnet" "eu-west-2a-private" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "eu-west-2a"
}
resource "aws_instance" "app" {
  ami = "${lookup(var.amis, var.region)}"
  availability_zone = "eu-west-2a"
  instance_type = "t2.micro"
  key_name = "${var.aws_key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.s3_profile.name}"
  vpc_security_group_ids = ["${aws_security_group.app.id}"]
  subnet_id = "${aws_subnet.eu-west-2a-private.id}"
  associate_public_ip_address = true
  source_dest_check = false
}
