pipeline {
    agent any

    environment {
        GITHUB_TOKEN = credentials('github-token')
        GITHUB_REPO = 'cyse7125-su24-team13/k8s-yaml-manifests'
        GITHUB_API_URL = 'https://api.github.com'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    def scmVars = checkout scm
                    def commitId = scmVars.GIT_COMMIT
                    env.GIT_COMMIT_ID = commitId
                }
            }
        }

        stage('Install and Configure Commitlint') {
            steps {
                sh '''
                    sudo apt-get update
                    sudo apt-get install -y nodejs npm
                    sudo npm install -g @commitlint/{cli,config-conventional}
                    echo "module.exports = { extends: ['@commitlint/config-conventional'] };" | sudo tee /var/lib/jenkins/commitlint.config.js
                '''
            }
        }

        stage('Commit Message Lint') {
            steps {
                sh '''
                    commitlint --config /var/lib/jenkins/commitlint.config.js --from=HEAD~1 --to=HEAD --verbose
                '''
            }
        }

        stage('Packer Validate') {
            steps {
                dir('packer') {
                    sh '''
                        packer init jenkins-ami.pkr.hcl
                        packer validate -var JENKINS_ADMIN_USERNAME="JENKINS_ADMIN_USERNAME" \
                                        -var JENKINS_ADMIN_PASSWORD="JENKINS_ADMIN_PASSWORD" \
                                        -var source_ami="SOURCE_AMI" \
                                        -var GITHUB_USERNAME="GHUB_USERNAME" \
                                        -var GITHUB_PASSWORD="GHUB_PASSWORD" \
                                        -var DOCKERHUB_USERNAME="DOCKERHUB_USERNAME" \
                                        -var DOCKERHUB_PASSWORD="DOCKERHUB_PASSWORD" \
                                        jenkins-ami.pkr.hcl
                    '''
                }
            }
        }
    }

    post {
        success {
            script {
                def commitId = env.GIT_COMMIT_ID
                def status = 'success'
                def description = 'packer validate successful.'
                notifyGithub(commitId, status, description)
            }
        }

        failure {
            script {
                def commitId = env.GIT_COMMIT_ID
                def status = 'failure'
                def description = 'packer validate failed.'
                notifyGithub(commitId, status, description)
            }
        }
    }
}

def notifyGithub(commitId, status, description) {
    def context = 'packer'
    def url = "${env.GITHUB_API_URL}/repos/${env.GITHUB_REPO}/statuses/${commitId}"

    def payload = [
        state       : status,
        target_url  : env.BUILD_URL,
        description : description,
        context     : context
    ]

    def response = sh(
        script: """#!/bin/bash
        curl -s -H "Authorization: token ${env.GITHUB_TOKEN}" \\
             -H "Content-Type: application/json" \\
             -d '${groovy.json.JsonOutput.toJson(payload)}' \\
             ${url}
        """,
        returnStdout: true
    ).trim()

    echo "GitHub API response: ${response}"
}
