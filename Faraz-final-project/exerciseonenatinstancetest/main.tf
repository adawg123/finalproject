
provider "aws" {
  region = "us-east-1"

}

resource "aws_security_group" "nat" {
  name = "testnat"
  description = "Allow services from the private subnet through NAT"

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
 
 }
 vpc_id = "vpc-064e424a4a2df8066"

}
# #include
resource "aws_eip" "test-nat-eip" {
  vpc = true
  depends_on = ["aws_instance.test-nat"]
}

# # resource "aws_route" "internet_access" {
# #   route_table_id         = "rtb-05b6a72a616f4e883"
# #   destination_cidr_block = "0.0.0.0/0"
# #   gateway_id             = "TestIGW"
# # }


# # Associate subnet public_subnet_eu_west_1a to public route table
# # resource "aws_route_table_association" "public_subnet_eu_west_1a_association" {
# #     subnet_id = "${aws_subnet.public_subnet_eu_west_1a.id}"
# #     route_table_id = "${aws_vpc.vpc_tuto.main_route_table_id}"
# # }


# # Associate subnet private_1_subnet_eu_west_1a to private route table
# #include
# resource "aws_route_table_association" "private_subnet_route_association" {
#     subnet_id = "subnet-0372debb4590d11bf"
#     route_table_id = "rtb-05b6a72a616f4e883"
# }
resource "aws_route_table" "publicnatinstancetointernet" {
  vpc_id = "vpc-064e424a4a2df8066"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-06e8679fd1f21f534"
  }
}

resource "aws_route_table" "privatetopublicnatinstance" {
  vpc_id = "vpc-064e424a4a2df8066"

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = "${aws_instance.test-nat.network_interface_id}"
  }
  depends_on = ["aws_instance.test-nat"]
}
# # connection {
# #     type     = "ssh"
# #     user     = "ubuntu"
# #     private_key  = "${file("~/downloads/fullstack.pem")}"
# #   }

# # include
resource "aws_instance" "test-nat" {
  ami = "ami-0422d936d535c63b1" # amzn-ami-vpc-nat-hvm-2015.03.0.x86_64-gp2
  availability_zone = "us-east-1b"
  instance_type = "t2.micro"
  key_name = "fullstack"
  security_groups = ["${aws_security_group.nat.id}"]
  subnet_id = "subnet-0be349b1964e8202c"
  associate_public_ip_address = true
  source_dest_check = false
#   depends_on = ["aws_security_group.nat"]
}