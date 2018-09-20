provider "aws" {
  region = "us-east-2"

}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "wordpress_terraform" {
  ami           = "ami-0552e3455b9bc8d50"
  instance_type = "t2.micro"
  security_groups = [
        "allow_http_https_ssh"
    ]
  key_name = "Ohio"
  tags {
    Name = "wordpress_terraform"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get install unzip"
    ]
    connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key  = "${file("~/downloads/Ohio.pem")}"
  }
  }
  
   provisioner "local-exec" {
    command = "ansible-playbook installwordpress.yml -i ${aws_instance.wordpress_terraform.public_ip}, -u ubuntu"
  }
}