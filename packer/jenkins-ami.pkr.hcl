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
  access_key    = var.aws_access_key
  secret_key    = var.aws_secret_key
  region        = var.region
  source_ami    = "ami-0a24670a6532ea110"
  instance_type = "t2.micro"
  ssh_username  = "ubuntu"
  ami_name      = "jenkins-ami-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y openjdk-11-jdk",
      "curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null",
      "echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y jenkins",
      "sudo apt-get install -y nginx",
      "sudo apt-get install -y certbot python3-certbot-nginx",
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /var/lib/jenkins/init.groovy.d",
      "sudo bash -c 'cat > /var/lib/jenkins/init.groovy.d/create-admin-user.groovy << EOF",
      "import jenkins.model.*",
      "import hudson.security.*",
      "println \"--> creating admin user\"",
      "def adminUsername = \"admin\"",
      "def adminPassword = \"admin123\"",
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
    "sudo sed -i 's/^Environment=\"JAVA_OPTS=-Djava\\.awt\\.headless=true\"$/Environment=\"JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false\"/' /lib/systemd/system/jenkins.service",
    "sudo systemctl daemon-reload",
    "sudo systemctl restart jenkins"
  ]
}


}
