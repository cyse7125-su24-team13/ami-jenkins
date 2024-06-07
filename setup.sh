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

# Stop Jenkins as final step if needed
sudo systemctl stop jenkins
