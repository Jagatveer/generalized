freeStyleJob('PR_job') {
  concurrentBuild(true)
  label('jnlp-slave')
  logRotator {
    numToKeep(100)
  }
  triggers {
    bitbucketBuildTrigger {
      projectPath('')
      cron('*/10 * * * *')
      credentialsId('bitbucket-credentials')
      username('')
      password('')
      repositoryOwner('nclouds')
      repositoryName('ken')
      branchesFilter('')
      branchesFilterBySCMIncludes(false)
      ciKey('')
      // This value is the name of the current job when showing build statuses for a pull request.
      ciName('jenkins')
      // A comma-separated list of strings to search the pull request title for.
      ciSkipPhrases('skip this please')
      checkDestinationCommit(false)
      approveIfSuccess(true)
      // If you make a new commit into your PR and there is already running job on that PR, this option will cancel such a outdated job and allows to run only one job at given PR with the newest commit.
      cancelOutdatedJobs(false)
      commentTrigger('test this please')
    }
  }

  steps {
     downstreamParameterized {
       trigger('TestBuild') {
          block {
            buildStepFailure('FAILURE')
            failure('FAILURE')
            unstable('UNSTABLE')
          }
         parameters {
           predefinedProp('BRANCH_NAME', '${sourceBranch}')
         }
       }
     }
   }

 }
