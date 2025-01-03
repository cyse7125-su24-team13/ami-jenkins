#!/bin/bash

# Update system packages
sudo apt-get update
sudo apt-get upgrade -y

# Install Java, which is needed for Jenkins
sudo apt-get install -y openjdk-11-jdk

# Add Jenkins repository and install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install -y jenkins

# Install Nginx and Certbot for SSL
sudo apt-get install -y nginx
sudo apt-get install -y certbot python3-certbot-nginx

# Prepare Jenkins initial configuration
sudo mkdir -p /var/lib/jenkins/init.groovy.d
sudo mv /tmp/create-admin-user.groovy /var/lib/jenkins/init.groovy.d/
sudo sed -i 's/^Environment="JAVA_OPTS=-Djava.awt.headless=true"$/Environment="JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"/' /lib/systemd/system/jenkins.service
sudo systemctl daemon-reload
sudo systemctl restart jenkins

# Wait for Jenkins to start up
sleep 30

# Jenkins CLI setup
JENKINS_CLI=jenkins-cli.jar
wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O $JENKINS_CLI
cat /tmp/plugins.txt | xargs -I {} java -jar jenkins-cli.jar -s http://localhost:8080/ -auth $1:$2 install-plugin {}

# Restart Jenkins to load plugins
sudo systemctl restart jenkins

# Wait for Jenkins to reload
sleep 30

# Install Docker
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add the current user to the Docker group
sudo usermod -aG docker jenkins

# Install unzip utility
sudo apt-get install -y unzip

# Install Terraform
TERRAFORM_VERSION="1.7.3"
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install Packer
PACKER_VERSION="1.7.8"
wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
unzip packer_${PACKER_VERSION}_linux_amd64.zip
sudo mv packer /usr/local/bin/
rm packer_${PACKER_VERSION}_linux_amd64.zip

# Install Node.js
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo \
  gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

# Create a deb repository
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo \
  tee /etc/apt/sources.list.d/nodesource.list

# Run update and install
sudo apt-get update && sudo apt-get install nodejs -y

# Handle credentials and other setup
CREDENTIAL_FILES=(
    "/tmp/final-github-token.xml"
    "/tmp/final-dockerhub-token.xml"
)

# Upload each credential
for file in "${CREDENTIAL_FILES[@]}"
do
    echo "Uploading credentials from $file"
    java -jar jenkins-cli.jar -s http://localhost:8080/ -auth $1:$2 create-credentials-by-xml system::system::jenkins "(global)" < $file
done

java -jar jenkins-cli.jar -s http://localhost:8080/ -auth $1:$2 groovy = < /tmp/seed-job.groovy

# Install Python, create virtual environment and install yamllint
sudo apt-get install -y python3 python3-venv
python3 -m venv /tmp/myenv
source /tmp/myenv/bin/activate
pip install --upgrade pip
pip install yamllint

# Edit sudoers file to allow jenkins user to run commands without password
echo "jenkins ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/jenkins

# Stop Jenkins as the final step if needed
sudo systemctl stop jenkins
