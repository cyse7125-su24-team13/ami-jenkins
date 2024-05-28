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

source "amazon-ebs" "ubuntu" {
  access_key    = var.aws_access_key
  secret_key    = var.aws_secret_key
  region        = var.region
  source_ami    = var.source_ami
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
      // Install dependencies
      "sudo apt-get install -y openjdk-11-jdk",
      // Install Jenkins
      "curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null",
      "echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y jenkins",
      // Install Nginx or Caddy
      "sudo apt-get install -y nginx",
      // Add Let's Encrypt
      "sudo apt-get install -y certbot python3-certbot-nginx",
    ]
  }

  provisioner "shell" {
    inline = [
      // Set up Nginx as reverse proxy
      "sudo rm /etc/nginx/sites-enabled/default",
      "sudo bash -c 'cat > /etc/nginx/sites-available/jenkins << EOF",
      "server {",
      "    listen 80;",
      "    server_name csye6225-vakiti.com;",
      "    location / {",
      "        proxy_pass http://127.0.0.1:8080;",
      "        proxy_set_header Host \\$host;",
      "        proxy_set_header X-Real-IP \\$remote_addr;",
      "        proxy_set_header X-Forwarded-For \\$proxy_add_x_forwarded_for;",
      "        proxy_set_header X-Forwarded-Proto \\$scheme;",
      "    }",
      "}",
      "EOF'",
      "sudo ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/",
      "sudo systemctl restart nginx",
      // Obtain SSL certificate
      //"sudo certbot --nginx -d jenkins.csye6225-vakiti.com --non-interactive --agree-tos -m vakiti.sai98@gmail.com",
    ]
  }
}
