multibranchPipelineJob('static-site') {
  branchSources {
    git {
        id('123456789') // IMPORTANT: use a constant and unique identifier
        remote('https://github.com/cyse7125-su24-team13/static-site.git')
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