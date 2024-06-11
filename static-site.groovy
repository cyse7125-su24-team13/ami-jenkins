multibranchPipelineJob('static-site') {
  branchSources {
    github {
      id('csye7125-static-site')
      scanCredentialsId('github-token')
      repoOwner('cyse7125-su24-team13')
      repository('static-site')
    }
  }

  orphanedItemStrategy {
    discardOldItems {
      numToKeep(-1)
      daysToKeep(-1)
    }
  }
}