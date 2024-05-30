variable "aws_access_key" {
  type      = string
  sensitive = true
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "region" {
  type    = string
}

variable "source_ami" {
  type    = string
}

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  region        = var.region
  source_ami    = var.source_ami
  instance_type = "t2.micro"
  ssh_username  = "ubuntu"
  ami_name      = "jenkins-ami-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
    source      = "../plugins.txt"
    destination = "/tmp/plugins.txt"
  }

  provisioner "file" {
    source      = "../create-admin-user.groovy"
    destination = "/tmp/create-admin-user.groovy"
  }

  provisioner "file" {
    source      = "../setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh"
    ]
  }
}
