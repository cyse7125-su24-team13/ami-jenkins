import jenkins.model.*
import hudson.model.*
import javaposse.jobdsl.plugin.ExecuteDslScripts
import javaposse.jobdsl.plugin.RemovedJobAction
import javaposse.jobdsl.plugin.LookupStrategy

String buildPushDockerJobName = "build-push-docker-image"
String prStatusCheckJobName = "infra-jenkins-jobdsl"
String prStatusCheckJobName_k8s = "k8s-yaml-manifests-jobdsl"
String prStatusCheckJobName_ami = "ami-jenkins-jobdsl"
String prStatusCheckJobName_helm = "helm-webapp-cve-processor-jobdsl"
String webappCveProcessorJobName = "webapp-cve-processor-jobdsl"
String dbMigrationJobName = "db-migration-jobdsl"
String prStatusCheckJobName_aws = "infra-aws-jobdsl"
String webappCveConsumerJobName = "webapp-cve-consumer-jobdsl"

String buildPushDockerJobDsl = """

pipelineJob('build-push-docker-image-pipeline') {
    description 'Pipeline job to build and push Docker image with multiplatform support.'

    environmentVariables {
        env('DOCKER_REPO', 'rahhul1309/static-site')
    }

    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/cyse7125-su24-team13/static-site.git')
                        credentials('github-token')
                    }
                    branches('*/main')
                }
            }
            scriptPath('Jenkinsfile')
            lightweight(true)
        }
    }

    triggers {
      githubPush()
    }
}
"""

String webappCveProcessorJobDsl = """

multibranchPipelineJob('csye7125-webapp-cve-processor') {
    description('Multibranch Pipeline job to build and validate YAML configurations for pull requests.')

    branchSources {
        github {
            id('csye7125-webapp-cve-processor-main')
            repoOwner('cyse7125-su24-team13')
            repository('webapp-cve-processor')
            scanCredentialsId('github-token')

            configure { node ->
                node / 'traits' << 'jenkins.branch.BranchDiscoveryTrait' {
                    strategyId(3)
                }
                node / 'traits' << 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait' {
                    strategyId(1)
                    trust(class: 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait\$TrustContributors')
                }
                node / 'traits' << 'org.jenkinsci.plugins.github__branch__source.OriginPullRequestDiscoveryTrait' {
                    strategyId(1)
                }
            }
        }
    }

    factory {
        workflowBranchProjectFactory {
            scriptPath('Jenkinsfile')
        }
    }

    triggers {
        periodicFolderTrigger {
            interval('1d')
        }
    }
}

"""


String prStatusCheckJobDsl = """
multibranchPipelineJob('csye7125-infra-jenkins') {
    description('Multibranch Pipeline job to build and validate Terraform configurations for pull requests.')

    branchSources {
        github {
            id('csye7125-infra-jenkins-main')
            repoOwner('cyse7125-su24-team13')
            repository('infra-jenkins')
            scanCredentialsId('github-token')

            configure { node ->
                node / 'traits' << 'jenkins.branch.BranchDiscoveryTrait' {
                    strategyId(3)
                }
                node / 'traits' << 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait' {
                    strategyId(1)
                    trust(class: 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait\$TrustContributors')
                }
                node / 'traits' << 'org.jenkinsci.plugins.github__branch__source.OriginPullRequestDiscoveryTrait' {
                    strategyId(1)
                }
            }
        }
    }

    factory {
        workflowBranchProjectFactory {
            scriptPath('Jenkinsfile')
        }
    }

    triggers {
        periodicFolderTrigger {
            interval('1d')
        }
    }
}

"""

String prStatusCheckJobDsl_k8s = """
multibranchPipelineJob('csye7125-k8s-yaml-manifests') {
    description('Multibranch Pipeline job to build and validate YAML configurations for pull requests.')

    branchSources {
        github {
            id('csye7125-k8s-yaml-manifests-main')
            repoOwner('cyse7125-su24-team13')
            repository('k8s-yaml-manifests')
            scanCredentialsId('github-token')

            configure { node ->
                node / 'traits' << 'jenkins.branch.BranchDiscoveryTrait' {
                    strategyId(3)
                }
                node / 'traits' << 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait' {
                    strategyId(1)
                    trust(class: 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait\$TrustContributors')
                }
                node / 'traits' << 'org.jenkinsci.plugins.github__branch__source.OriginPullRequestDiscoveryTrait' {
                    strategyId(1)
                }
            }
        }
    }

    factory {
        workflowBranchProjectFactory {
            scriptPath('Jenkinsfile')
        }
    }

    triggers {
        periodicFolderTrigger {
            interval('1d')
        }
    }
}

"""

String prStatusCheckJobDsl_ami = """
multibranchPipelineJob('csye7125-ami-jenkins') {
    description('Multibranch Pipeline job to build and validate Terraform configurations for pull requests.')

    branchSources {
        github {
            id('csye7125-ami-jenkins-main')
            repoOwner('cyse7125-su24-team13')
            repository('ami-jenkins')
            scanCredentialsId('github-token')

            configure { node ->
                node / 'traits' << 'jenkins.branch.BranchDiscoveryTrait' {
                    strategyId(3)
                }
                node / 'traits' << 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait' {
                    strategyId(1)
                    trust(class: 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait\$TrustContributors')
                }
                node / 'traits' << 'org.jenkinsci.plugins.github__branch__source.OriginPullRequestDiscoveryTrait' {
                    strategyId(1)
                }
            }
        }
    }

    factory {
        workflowBranchProjectFactory {
            scriptPath('Jenkinsfile')
        }
    }

    triggers {
        periodicFolderTrigger {
            interval('1d')
        }
    }
}

"""

String prStatusCheckJobDsl_helm = """
multibranchPipelineJob('csye7125-helm-cve-processor') {
    description('Multibranch Pipeline job to build and validate Terraform configurations for pull requests.')

    branchSources {
        github {
            id('csye7125-helm-cve-processor-main')
            repoOwner('cyse7125-su24-team13')
            repository('helm-webapp-cve-processor')
            scanCredentialsId('github-token')

            configure { node ->
                node / 'traits' << 'jenkins.branch.BranchDiscoveryTrait' {
                    strategyId(3)
                }
                node / 'traits' << 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait' {
                    strategyId(1)
                    trust(class: 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait\$TrustContributors')
                }
                node / 'traits' << 'org.jenkinsci.plugins.github__branch__source.OriginPullRequestDiscoveryTrait' {
                    strategyId(1)
                }
            }
        }
    }

    factory {
        workflowBranchProjectFactory {
            scriptPath('Jenkinsfile')
        }
    }

    triggers {
        periodicFolderTrigger {
            interval('1d')
        }
    }
}
"""

String dbMigrationJobDsl = """

multibranchPipelineJob('csye7125-DB-migration') {
    description('Multibranch Pipeline job to build and validate YAML configurations for pull requests.')

    branchSources {
        github {
            id('csye7125-DB-migration-main')
            repoOwner('cyse7125-su24-team13')
            repository('DB-migration')
            scanCredentialsId('github-token')

            configure { node ->
                node / 'traits' << 'jenkins.branch.BranchDiscoveryTrait' {
                    strategyId(3)
                }
                node / 'traits' << 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait' {
                    strategyId(1)
                    trust(class: 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait\$TrustContributors')
                }
                node / 'traits' << 'org.jenkinsci.plugins.github__branch__source.OriginPullRequestDiscoveryTrait' {
                    strategyId(1)
                }
            }
        }
    }

    factory {
        workflowBranchProjectFactory {
            scriptPath('Jenkinsfile')
        }
    }

    triggers {
        periodicFolderTrigger {
            interval('1d')
        }
    }
}

"""

String prStatusCheckJobDsl_aws = """
multibranchPipelineJob('csye7125-infra-aws') {
    description('Multibranch Pipeline job to build and validate Terraform configurations for pull requests.')

    branchSources {
        github {
            id('csye7125-infra-aws-main')
            repoOwner('cyse7125-su24-team13')
            repository('infra-aws')
            scanCredentialsId('github-token')

            configure { node ->
                node / 'traits' << 'jenkins.branch.BranchDiscoveryTrait' {
                    strategyId(3)
                }
                node / 'traits' << 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait' {
                    strategyId(1)
                    trust(class: 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait\$TrustContributors')
                }
                node / 'traits' << 'org.jenkinsci.plugins.github__branch__source.OriginPullRequestDiscoveryTrait' {
                    strategyId(1)
                }
            }
        }
    }

    factory {
        workflowBranchProjectFactory {
            scriptPath('Jenkinsfile')
        }
    }

    triggers {
        periodicFolderTrigger {
            interval('1d')
        }
    }
}
"""

String webappCveConsumerJobDsl = """
multibranchPipelineJob('csye7125-webapp-cve-consumer') {
    description('Multibranch Pipeline job to build and validate YAML configurations for pull requests.')

    branchSources {
        github {
            id('csye7125-webapp-cve-consumer-main')
            repoOwner('cyse7125-su24-team13')
            repository('webapp-cve-consumer')
            scanCredentialsId('github-token')

            configure { node ->
                node / 'traits' << 'jenkins.branch.BranchDiscoveryTrait' {
                    strategyId(3)
                }
                node / 'traits' << 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait' {
                    strategyId(1)
                    trust(class: 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait\$TrustContributors')
                }
                node / 'traits' << 'org.jenkinsci.plugins.github__branch__source.OriginPullRequestDiscoveryTrait' {
                    strategyId(1)
                }
            }
        }
    }

    factory {
        workflowBranchProjectFactory {
            scriptPath('Jenkinsfile')
        }
    }

    triggers {
        periodicFolderTrigger {
            interval('1d')
        }
    }
}
"""


// Function to create or update a job
def createOrUpdateJob(String jobName, String jobDsl) {
    def jenkins = Jenkins.getInstanceOrNull()
    if (jenkins == null) {
        throw new IllegalStateException("Jenkins instance is not available")
    }
    
    Item job = jenkins.getItem(jobName)
    if (job == null) {  // Job does not exist, create new
        job = jenkins.createProject(FreeStyleProject, jobName)
    }

    if (job instanceof FreeStyleProject) {
        ExecuteDslScripts executeDslScripts = new ExecuteDslScripts()
        executeDslScripts.setScriptText(jobDsl)
        executeDslScripts.setRemovedJobAction(RemovedJobAction.DELETE)
        executeDslScripts.setLookupStrategy(LookupStrategy.JENKINS_ROOT)

        // Run the DSL script
        job.getBuildersList().clear()  // Clear existing builders
        job.getBuildersList().add(executeDslScripts)
        job.save()
        jenkins.reload()
    }
}

// Create or update the jobs
createOrUpdateJob(buildPushDockerJobName, buildPushDockerJobDsl)
createOrUpdateJob(prStatusCheckJobName, prStatusCheckJobDsl)
createOrUpdateJob(prStatusCheckJobName_k8s, prStatusCheckJobDsl_k8s)
createOrUpdateJob(prStatusCheckJobName_ami, prStatusCheckJobDsl_ami)
createOrUpdateJob(prStatusCheckJobName_helm, prStatusCheckJobDsl_helm)
createOrUpdateJob(webappCveProcessorJobName, webappCveProcessorJobDsl)
createOrUpdateJob(dbMigrationJobName, dbMigrationJobDsl)
createOrUpdateJob(prStatusCheckJobName_aws, prStatusCheckJobDsl_aws)
createOrUpdateJob(webappCveConsumerJobName, webappCveConsumerJobDsl)
