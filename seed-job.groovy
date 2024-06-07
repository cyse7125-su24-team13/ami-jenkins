import jenkins.model.*
import hudson.model.*
import hudson.model.FreeStyleProject
import javaposse.jobdsl.plugin.ExecuteDslScripts
import javaposse.jobdsl.plugin.RemovedJobAction
import javaposse.jobdsl.plugin.LookupStrategy

String jobName = "build-docker-image"
String jobDsl = """
pipelineJob('build-docker-image') {
    description 'Pipeline job to build and push Docker image with multiplatform support.'

    // Environment variables can be set here if required
    environmentVariables {
        env('DOCKER_REPO', 'rahhul1309/static-site')
    }

    // Set up the SCM to point to the Git repository with the Jenkinsfile
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
            scriptPath('Jenkinsfile') // Path to the Jenkinsfile in the Git repository
            lightweight(true) // Use lightweight checkout if possible
        }
    }

    triggers {
      githubPush()
    }
}
"""

Jenkins jenkins = Jenkins.instance
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
