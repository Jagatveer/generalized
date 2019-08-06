pipelineJob('TestBuild') {
  parameters {
    stringParam('BRANCH_NAME', 'master', 'branch name to build the docker image')
  }
  logRotator {
    numToKeep(100)
  }
  definition {
    cps {
      script(readFileFromWorkspace('jobs/pipeline/testKenImage.groovy'))
      sandbox()
    }
  }
}
