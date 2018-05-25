variable docker_ubuntu_ami {}
variable key_name {}

provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "login" {
  key_name   = "${var.key_name}"
  public_key = "${file("/tmp/${var.key_name}.pub")}"
}

resource "aws_instance" "docker" {
  ami           = "${var.docker_ubuntu_ami}"
  instance_type = "t2.medium"

  key_name = "${var.key_name}"

  tags {
    Name = "Puppet-Stack"
  }

  security_groups = [
    "Totally Not Safe TCP",
  ]

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /var/lib/puppet-docker",
      "sudo git clone https://github.com/puppetlabs/puppet-in-docker-examples.git /var/lib/puppet-docker",
      "cd /var/lib/puppet-docker/compose",
      "sudo docker-compose up",
      "echo 'PRINTING RUNNING INSTANCES AND ACCESS PORTS:'",
      "sudo docker ps -a",
    ]

    connection {
      user        = "ubuntu"
      private_key = "${file("/tmp/${var.key_name}")}"
    }
  }

  provisioner "local-exec" {
    command = "echo YOUR PUPPET STACK ADDRESS IS: http://${aws_instance.docker.public_dns}"
  }
}
