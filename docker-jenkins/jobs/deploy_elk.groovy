freeStyleJob('deploy-elk') {
  label('jnlp-slave')
  description('Deploys elk stack from ecs-refarch-cloudformation using CodeDeploy')

  logRotator {
    numToKeep(10)
  }

  parameters {
    stringParam('BRANCH_NAME', 'master', 'The branch in ecs-refarch-repo to be deployed')
  }

  scm {
    git {
      remote {
        url('git@bitbucket.org:nclouds/ecs-refarch-cloudformation.git')
        credentials('bitbucket-ssh')
      }
      branches('${BRANCH_NAME}')
    }
  }

  steps {
    shell('''\
        #!/bin/bash
        set -xe
        cd infrastructure/logging/

        echo "Pushing revision to s3"

        aws deploy push \
          --application-name nops-elk \
          --description "This is a revision for the application nops-elk" \
          --ignore-hidden-files --region us-west-2 \
          --s3-location s3://carlos-cf-templates/nops-elk-releases/nops-elk.zip \
          --source .

        echo "Deploying new revision with CodeDeploy"

        aws deploy create-deployment --application-name nops-elk \
        --s3-location bucket=carlos-cf-templates,key=nops-elk-releases/nops-elk.zip,bundleType=zip \
        --deployment-group-name nops-elk --region us-west-2 --description "Release for nOps elk"
        ''')
  }

}
