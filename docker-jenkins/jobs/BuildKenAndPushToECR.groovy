pipelineJob('BuildKenAndPushToECR') {
    parameters {
      stringParam('REPOSITORY_CLONE_ADDRESS','git@bitbucket.org:nclouds/ken.git','ssh clone address of the repository where dockerfile is present')
      stringParam('REGISTRY_NAME','https://202279780353.dkr.ecr.us-west-2.amazonaws.com','name of the ecr')
      stringParam('BRANCH_NAME', 'master', 'branch')
      booleanParam('CELERY_REFRESH', false, 'fill the checkbox to restart the CELERY REFRESH WORKER in the deployment')
      booleanParam('MIGRATION',false,'fill the checkbox to realize a migartion in the database')
    }

    logRotator {
      numToKeep(100)
    }

    definition {
        cpsScm {
          scm {
            git {
              branch('${BRANCH_NAME}')
              remote {
                  url('git@bitbucket.org:nclouds/ken.git')
                  credentials('bitbucket-ssh')
              }
            }
          }
          scriptPath('Jenkinsfile')
        }
    }
}
