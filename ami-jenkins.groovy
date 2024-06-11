multibranchPipelineJob('ami-jenkins') {
  branchSources {
    git {
        id('csye7125-ami-jenkins') // IMPORTANT: use a constant and unique identifier
        remote('https://github.com/cyse7125-su24-team13/ami-jenkins.git')
        credentialsId('github-token')
        includes('JENKINS-*')
    }
  }

  orphanedItemStrategy {
    discardOldItems {
      numToKeep(-1)
      daysToKeep(-1)
    }
  }
}