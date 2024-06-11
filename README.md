# ami-jenkins

## Overview
This repository contains the necessary files and instructions to create a custom Jenkins AMI using Packer. The Jenkins instance will be set up with a reverse proxy (Caddy or Nginx) that obtains SSL certificates from Let's Encrypt.


## Prerequisites
- AWS account with root access
- AWS CLI installed and configured
- Packer installed
- GitHub repository set up with the necessary permissions
- Ubuntu 24.04 LTS as the base image for the AMI

## Setup Instructions

### AWS CLI Configuration
1. Install and configure the AWS CLI on your development machine.
   ```bash
   aws configure --profile dev
   aws configure --profile prod

### Packer Build Commands
git clone https://github.com/cyse7125-su24-teamNN/ami-jenkins.git.
    ```bash

    
    cd ami-jenkins
    packer validate jenkins-ami.pkr.hcl
    packer build jenkins-ami.pkr.hcl
    hi

