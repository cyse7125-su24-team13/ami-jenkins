variable "JENKINS_ADMIN_USERNAME" {
  type    = string
}

variable "JENKINS_ADMIN_PASSWORD" {
  type    = string
}

variable "GITHUB_USERNAME" {
  type    = string
}

variable "GITHUB_PASSWORD" {
  type    = string
}

variable "DOCKERHUB_USERNAME" {
  type    = string
}

variable "DOCKERHUB_PASSWORD" {
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
  source_ami    = var.source_ami
  instance_type = "t2.small"
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
    source      = "../setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "file" {
    source      = "../seed-job.groovy"
    destination = "/tmp/seed-job.groovy"
  }

  provisioner "file" {
    source      = "../jenkins-credentials/github-token.xml"
    destination = "/tmp/github-token.xml"
  }

  provisioner "file" {
    source      = "../jenkins-credentials/dockerhub-token.xml"
    destination = "/tmp/dockerhub-token.xml"
  }

  provisioner "shell"{
    inline = [
      "export GITHUB_USERNAME=\"${var.GITHUB_USERNAME}\"",
      "export GITHUB_PASSWORD=\"${var.GITHUB_PASSWORD}\"",
      "export AUTH=\"${var.JENKINS_ADMIN_USERNAME}:${var.JENKINS_ADMIN_PASSWORD}\"",
      "export DOCKERHUB_USERNAME=\"${var.DOCKERHUB_USERNAME}\"",
      "export DOCKERHUB_PASSWORD=\"${var.DOCKERHUB_PASSWORD}\"",
      "envsubst < /tmp/github-token.xml > /tmp/final-github-token.xml",
      "envsubst < /tmp/dockerhub-token.xml > /tmp/final-dockerhub-token.xml",
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo bash -c 'cat > /tmp/create-admin-user.groovy << EOF",
      "import jenkins.model.*",
      "import hudson.security.*",
      "println \"--> creating admin user\"",
      "def adminUsername = \"${var.JENKINS_ADMIN_USERNAME}\"",
      "def adminPassword = \"${var.JENKINS_ADMIN_PASSWORD}\"",
      "assert adminPassword != null : \"No ADMIN_USERNAME env var provided, but required\"",
      "assert adminPassword != null : \"No ADMIN_PASSWORD env var provided, but required\"",
      "def hudsonRealm = new HudsonPrivateSecurityRealm(false)",
      "hudsonRealm.createAccount(adminUsername, adminPassword)",
      "Jenkins.instance.setSecurityRealm(hudsonRealm)",
      "def strategy = new FullControlOnceLoggedInAuthorizationStrategy()",
      "strategy.setAllowAnonymousRead(false)",
      "Jenkins.instance.setAuthorizationStrategy(strategy)",
      "Jenkins.instance.save()",
      "EOF'"
    ]
  }


  provisioner "shell" {
  inline = [
    "chmod +x /tmp/setup.sh",
    "sudo /tmp/setup.sh ${var.JENKINS_ADMIN_USERNAME} ${var.JENKINS_ADMIN_PASSWORD}"
  ]
}

}
