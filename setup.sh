#!/bin/bash

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y openjdk-11-jdk
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install -y jenkins
sudo apt-get install -y nginx
sudo apt-get install -y certbot python3-certbot-nginx
sudo mkdir -p /var/lib/jenkins/init.groovy.d
sudo mv /tmp/create-admin-user.groovy /var/lib/jenkins/init.groovy.d/
sudo sed -i 's/^Environment="JAVA_OPTS=-Djava\\.awt\\.headless=true"$/Environment="JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"/' /lib/systemd/system/jenkins.service
sudo systemctl daemon-reload
sudo systemctl restart jenkins

# Wait for Jenkins to be fully up and running
echo "Waiting for Jenkins to start..."
while ! curl -s http://localhost:8080/login > /dev/null; do
    sleep 10
done
echo "Jenkins is up and running"

JENKINS_CLI=jenkins-cli.jar
wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O $JENKINS_CLI
cat /tmp/plugins.txt | xargs -I {} java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:admin123 install-plugin {}
sudo systemctl stop jenkins
